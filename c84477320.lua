--星辰響手プリクル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「星辰响手 金牛魔」以外的自己墓地1只「星辰」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上1只怪兽回到手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以「星辰响手 金牛魔」以外的自己墓地1只「星辰」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上1只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中除「星辰响手 金牛魔」之外，并且能够特殊召唤的「星辰」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c9) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向，检测目标卡片位置与过滤条件，并注册特殊召唤与回到手牌的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 若为检测阶段，则先确认己方主要怪兽区域是否有可用的空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认自己墓地中存在至少1只可以成为效果对象的「星辰」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择需要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只符合条件的怪兽，并设定为当前效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为将选取的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置当前连锁的操作信息为将自己场上的1只怪兽送回持有者手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
-- 特殊召唤效果的操作空间，特殊召唤墓地对象怪兽，若成功则让场上的1只怪兽回到手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段设定的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若该卡片不受王家长眠之谷的影响且依然存在于连锁中，则将其以表侧表示特殊召唤
	if tc and aux.NecroValleyFilter()(tc) and tc:IsRelateToChain() and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使后续将自己场上怪兽送回手牌的处理视为不同时处理
		Duel.BreakEffect()
		-- 向玩家发送选择返回手牌怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 让玩家选择自己场上1只可以返回手牌的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			-- 手动在场上高亮显示选择返回手牌的怪兽
			Duel.HintSelection(g)
			-- 通过效果处理将所选取的怪兽送回玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 判断盖放魔陷效果的发动条件，须为这张卡作为融合素材送入墓地
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤卡组中可以被在自己场上盖放的「星辰」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的靶向，检测卡组是否存在符合盖放要求的「星辰」魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则返回卡组中是否存在可盖放的「星辰」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的操作空间，从卡组选择1张符合条件的「星辰」魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择盖放卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足条件的「星辰」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选取的魔法·陷阱卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
