--粛声の祈り手ロー
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「肃声」永续魔法·永续陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：战士族·龙族而光属性的仪式怪兽1只仪式召唤的场合，可以由这1张卡作为仪式召唤需要的数值的解放使用。
-- ③：这张卡在墓地存在的状态，自己场上有战士族·龙族而光属性的仪式怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡注册①（召唤·特殊召唤时从卡组放置「肃声」永续魔陷）、②（作为战士族·龙族光属性仪式怪兽仪式召唤的数值解放）、③（墓地存在时自己场上有符合条件的仪式怪兽特殊召唤则特殊召唤自身）三个效果，并分别设置1回合1次的同名卡次数限制。
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
	-- 为这张卡注册“已在墓地”的标记检测效果，记录其进入墓地的事实，供③效果发动条件判断使用，防止同一连锁中反复判定。
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
-- 筛选卡组中符合条件的卡：永续魔法·永续陷阱、属于「肃声」字段、未被禁止且满足场上唯一性（不能与场上已有卡同名）。
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x1a6)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果发动条件：自己魔陷区有空位，且卡组存在符合条件的「肃声」永续魔法·永续陷阱。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足s.pfilter条件的「肃声」永续魔法/陷阱。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ①效果处理：从卡组选择1张符合条件的「肃声」永续魔法·永续陷阱，表侧表示放置到自己的魔法与陷阱区域。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认魔陷区仍有空位，若已无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 发送选择提示，让玩家从卡组选择一张要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选取1张满足s.pfilter的「肃声」永续魔法·永续陷阱。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 若选到了卡，则将其以表侧表示放置到自己的魔法与陷阱区域，并立即适用其效果。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 作为仪式解放等级计算：若被解放的仪式怪兽为战士族/龙族·光属性，则本卡可当作等级从该怪兽等级到本卡等级之间的数值用于仪式召唤；否则仅当作本卡原等级。
function s.rlevel(e,c)
	-- 获取本卡被限制在安全上限内的等级数值。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsRace(RACE_WARRIOR+RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- ③效果触发怪兽过滤：特殊召唤成功的怪兽需满足表侧表示、战士族或龙族、光属性、仪式怪兽、由自己控制，且该特殊召唤的原因效果不是本卡③效果（避免与本效果形成循环）。
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR+RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_RITUAL)
		and (se==nil or c:GetReasonEffect()~=se) and c:IsControler(tp)
end
-- ③效果的发动条件：当满足s.cfilter的仪式怪兽被特殊召唤成功时，且该召唤不是由本效果③自身导致的情况下，条件成立。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- ③效果的目标检查：自己主要怪兽区有空位，且墓地中的本卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的操作信息：将特殊召唤墓地的这张卡的操作类别设为CATEGORY_SPECIAL_SUMMON，以便相关卡进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：如果墓地中的本卡仍与效果关联，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地中的本卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
