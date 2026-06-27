--ワーム・キング
-- 效果：
-- 这张卡可以用1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，对方场上1张卡破坏。
function c10026986.initial_effect(c)
	-- 简易上级召唤：可以使用1只「异虫」爬虫类族怪兽进行上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10026986,0))  --"用1只怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c10026986.otcon)
	e1:SetOperation(c10026986.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 破坏效果：解放我方场上1只「异虫」爬虫类族怪兽，破坏对方场上1张卡
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
-- 过滤作为解放祭品的「异虫」爬虫类族怪兽
function c10026986.cfilter(c,tp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤条件检查：检查是否能用1只怪兽解放进行攻击表示召唤
function c10026986.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取可解放作为祭品的「异虫」爬虫类族怪兽组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查是否可以通过解放1只怪兽完成上级召唤
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤操作：解放怪兽
function c10026986.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取可解放的怪兽组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择1只作为上级召唤祭品的怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放所选择的怪兽以进行召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 破坏效果的Cost：解放我方场上的1只怪虫怪兽
function c10026986.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的「异虫」爬虫类族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c10026986.cfilter,1,nil,tp) end
	-- 选择我方场上的1只怪兽作为解放Cost
	local sg=Duel.SelectReleaseGroup(tp,c10026986.cfilter,1,1,nil,tp)
	-- 解放选定的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 破坏效果的目标选择与锁定
function c10026986.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 声明破坏目标卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际操作
function c10026986.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选中的对方卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将选中的卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
