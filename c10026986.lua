--ワーム・キング
-- 效果：
-- 这张卡可以用1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，对方场上1张卡破坏。
function c10026986.initial_effect(c)
	-- 这张卡可以用1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10026986,0))  --"用1只怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c10026986.otcon)
	e1:SetOperation(c10026986.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10026986,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c10026986.descost)
	e2:SetTarget(c10026986.destg)
	e2:SetOperation(c10026986.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断卡片是否属于「异虫」系列，且为爬虫类族，且在自己场上表侧表示（或在对应玩家控制下）
function c10026986.cfilter(c,tp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤手续条件检查：判断被召唤的卡是否为7星以上怪兽，且要求的祭品数为1只，且场上存在符合召唤条件的「异虫」怪兽
function c10026986.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有符合「异虫」爬虫类族条件的怪兽作为祭品候选组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断这张卡是否为7星以上怪兽，且要求的祭品数为1，且场上存在可供解放的符合条件的祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤手续的祭品选择与解放执行：获取符合条件的卡片组，让玩家选择1只作为祭品，并将其解放
function c10026986.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有符合「异虫」爬虫类族条件的怪兽
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只用于上级召唤的祭品怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤和材料的原因解放选择的祭品怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 破坏效果的发动代价：检查场上是否存在符合条件的「异虫」爬虫类族怪兽，并让玩家选择1只解放
function c10026986.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动代价检查：判断场上是否存在至少1张符合条件的「异虫」怪兽可以被解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c10026986.cfilter,1,nil,tp) end
	-- 让玩家选择1张符合条件的「异虫」怪兽作为解放代价
	local sg=Duel.SelectReleaseGroup(tp,c10026986.cfilter,1,1,nil,tp)
	-- 以支付效果代价的原因解放选择的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 破坏效果的目标选择：判断对方场上是否存在可以被选择为破坏目标的卡，若有则选择其为效果对象
function c10026986.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 效果发动时的目标检查：判断对方场上是否存在至少1张可以被选择为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：在连锁中注册破坏操作，目标为选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行操作：若对象卡仍在场，则将其破坏
function c10026986.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
