--インヴェルズ・ギラファ
-- 效果：
-- 这张卡可以把1只名字带有「侵入魔鬼」的怪兽解放表侧攻击表示上级召唤。把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，可以选择对方场上存在的1张卡送去墓地，自己回复1000基本分。
function c58494728.initial_effect(c)
	-- 这张卡可以把1只名字带有「侵入魔鬼」的怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58494728,0))  --"用一只怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c58494728.otcon)
	e1:SetOperation(c58494728.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，可以选择对方场上存在的1张卡送去墓地，自己回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58494728,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c58494728.condition)
	e2:SetTarget(c58494728.target)
	e2:SetOperation(c58494728.operation)
	c:RegisterEffect(e2)
	-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c58494728.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤用于上级召唤的「侵入魔鬼」怪兽（自己场上的，或者对方场上表侧表示的）
function c58494728.otfilter(c,tp)
	return c:IsSetCard(0x100a) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判定是否满足用1只「侵入魔鬼」怪兽解放进行上级召唤的条件
function c58494728.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上可作为解放祭品的「侵入魔鬼」怪兽组
	local mg=Duel.GetMatchingGroup(c58494728.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定这张卡是否为7星以上、最少解放数量不大于1，且场上存在至少1只可解放的「侵入魔鬼」怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行用1只「侵入魔鬼」怪兽解放进行上级召唤的操作
function c58494728.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上可作为解放祭品的「侵入魔鬼」怪兽组
	local mg=Duel.GetMatchingGroup(c58494728.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只用于上级召唤的「侵入魔鬼」怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的素材
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查上级召唤的素材中是否存在「侵入魔鬼」怪兽，并为效果2设置对应的Label标记
function c58494728.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x100a) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判定此卡是否上级召唤成功，且解放的素材中包含「侵入魔鬼」怪兽
function c58494728.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 效果2的发动准备：选择对方场上1张卡作为对象，并注册送去墓地和回复生命值的操作信息
function c58494728.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判定对方场上是否存在可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置效果处理信息：自己回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果2的实际处理：将选中的卡送去墓地，若成功送去墓地则自己回复1000基本分
function c58494728.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
		-- 若目标卡成功送去墓地，则自己回复1000基本分
		if tc:IsLocation(LOCATION_GRAVE) then Duel.Recover(tp,1000,REASON_EFFECT) end
	end
end
