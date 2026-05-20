--ブラックマンバ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有爬虫类族怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。从卡组把1只爬虫类族怪兽送去墓地，作为对象的怪兽的表示形式变更。
function c86469231.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有爬虫类族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86469231,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,86469231+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c86469231.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。从卡组把1只爬虫类族怪兽送去墓地，作为对象的怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86469231,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,86469232)
	e2:SetTarget(c86469231.tgtg)
	e2:SetOperation(c86469231.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的爬虫类族怪兽
function c86469231.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 特殊召唤规则的条件：自己场上有爬虫类族怪兽存在，且自身怪兽区域有空位
function c86469231.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的爬虫类族怪兽
		and Duel.IsExistingMatchingCard(c86469231.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中可以送去墓地的爬虫类族怪兽
function c86469231.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 过滤条件：可以变更表示形式的怪兽
function c86469231.posfilter(c)
	return c:IsCanChangePosition()
end
-- 效果②的发动准备与目标选择：检查对方场上是否有可变更表示形式的怪兽，以及卡组中是否有可送去墓地的爬虫类族怪兽
function c86469231.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c86469231.posfilter(chkc) end
	-- 在发动检查阶段，检查对方场上是否存在至少1只可以变更表示形式的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c86469231.posfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 并且检查自己卡组中是否存在至少1只可以送去墓地的爬虫类族怪兽
		and Duel.IsExistingMatchingCard(c86469231.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要变更表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只可以变更表示形式的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86469231.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理信息：变更所选对象的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果②的效果处理：从卡组将1只爬虫类族怪兽送去墓地，若成功则变更对象怪兽的表示形式
function c86469231.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c86469231.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选择的怪兽送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取发动的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 变更该对象怪兽的表示形式
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
