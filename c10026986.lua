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
-- 过滤场上「异虫」爬虫类族怪兽的过滤函数
function c10026986.cfilter(c,tp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判定是否满足可以用1只「异虫」爬虫类族怪兽解放进行上级召唤的条件函数
function c10026986.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上可用于解放的「异虫」爬虫类族怪兽卡组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查自身等级是否在7星以上、最小祭品数是否小于等于1，以及场上是否存在1只符合解放条件的怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行用1只「异虫」爬虫类族怪兽解放进行上级召唤的具体操作函数
function c10026986.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上可用于解放的「异虫」爬虫类族怪兽卡组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只用于解放进行上级召唤的「异虫」爬虫类族怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选取的祭品怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 破坏效果的代价函数，需要解放自己场上1只「异虫」爬虫类族怪兽
function c10026986.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只可用于解放的「异虫」爬虫类族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c10026986.cfilter,1,nil,tp) end
	-- 让玩家选择自己场上1只可用于解放的「异虫」爬虫类族怪兽
	local sg=Duel.SelectReleaseGroup(tp,c10026986.cfilter,1,1,nil,tp)
	-- 解放选取的怪兽以支付发动代价
	Duel.Release(sg,REASON_COST)
end
-- 破坏效果的靶指向目标选择函数，确认并选取对方场上1张卡作为破坏对象
function c10026986.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在可以作为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送选择要破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的信息，操作类型为破坏，目标为选择的卡片，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理操作函数
function c10026986.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏选取的对象卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
