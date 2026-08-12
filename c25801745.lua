--粛声の祈り手ロー
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「肃声」永续魔法·永续陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：战士族·龙族而光属性的仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的数值的解放使用。
-- ③：这张卡在墓地存在的状态，自己场上有战士族·龙族而光属性的仪式怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片的4个效果：①通常召唤成功时发动的效果、②特殊召唤成功时发动的效果、③仪式怪兽等级计算效果、④墓地发动的特殊召唤效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「肃声」永续魔法·永续陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：战士族·龙族而光属性的仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的数值的解放使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_RITUAL_LEVEL)
	e3:SetValue(s.rlevel)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的状态，自己场上有战士族·龙族而光属性的仪式怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	-- 为该卡注册一个送入墓地时触发的单次效果，用于标记该卡是否已进入墓地
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetLabelObject(e0)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查卡组中是否存在满足条件的「肃声」永续魔法或陷阱卡
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x1a6)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果处理函数：判断是否满足发动条件，即是否有足够的魔法与陷阱区域，以及卡组中是否存在符合条件的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断卡组中是否存在符合条件的「肃声」永续魔法或陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果处理函数：选择并放置一张符合条件的「肃声」永续魔法或陷阱卡到魔法与陷阱区域
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否还有魔法与陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张符合条件的「肃声」永续魔法或陷阱卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 将选中的卡移动到魔法与陷阱区域
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 计算仪式怪兽等级的函数：若为战士族+龙族+光属性，则返回等级组合值
function s.rlevel(e,c)
	-- 获取该卡的等级值（安全阈值内）
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsRace(RACE_WARRIOR+RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 过滤函数：判断场上是否有满足条件的战士族+龙族+光属性的仪式怪兽
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR+RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_RITUAL)
		and (se==nil or c:GetReasonEffect()~=se) and c:IsControler(tp)
end
-- 墓地发动效果的条件函数：判断是否有满足条件的仪式怪兽被特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- 墓地发动效果的目标函数：判断是否可以将该卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地发动效果的处理函数：将该卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作：将该卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
