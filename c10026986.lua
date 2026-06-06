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
-- 过滤条件：判断是否为名字带有「异虫」的爬虫类族怪兽
function c10026986.cfilter(c,tp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤条件判断：判断是否为7星以上怪兽，且只用1只祭品，且场上存在符合条件的祭品
function c10026986.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上名字带有「异虫」的爬虫类族怪兽组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断此卡是否为7星以上怪兽，且只用1只祭品，且场上存在符合条件的祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤处理：选择1只场上符合条件的名字带有「异虫」的爬虫类族怪兽解放
function c10026986.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上名字带有「异虫」的爬虫类族怪兽组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择1只场上符合条件的名字带有「异虫」的爬虫类族怪兽作为召唤的解放素材
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选择的怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 破坏效果的发动代价处理：解放自己场上1只名字带有「异虫」的爬虫类族怪兽
function c10026986.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以解放的名字带有「异虫」的爬虫类族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c10026986.cfilter,1,nil,tp) end
	-- 从自己场上选择1只名字带有「异虫」的爬虫类族怪兽
	local sg=Duel.SelectReleaseGroup(tp,c10026986.cfilter,1,1,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(sg,REASON_COST)
end
-- 破坏效果的发动条件与对象选择：选择对方场上1张卡为对象，设定破坏的操作信息
function c10026986.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在可以破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理：将选中的对方场上的卡破坏
function c10026986.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果将该卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
