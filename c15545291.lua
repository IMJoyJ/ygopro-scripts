--剛地帝グランマーグ
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。这张卡上级召唤成功时，选择场上盖放的最多2张卡破坏。这张卡把地属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
-- ●从卡组抽1张卡。
function c15545291.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15545291,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c15545291.otcon)
	e1:SetOperation(c15545291.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 这张卡上级召唤成功时，选择场上盖放的最多2张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15545291,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c15545291.descon)
	e3:SetTarget(c15545291.destg)
	e3:SetOperation(c15545291.desop)
	c:RegisterEffect(e3)
	-- 这张卡把地属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。●从卡组抽1张卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c15545291.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤出场上所有上级召唤的怪兽
function c15545291.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 判断是否满足上级召唤条件：等级不低于7，最少需要1个祭品，且场上存在满足条件的祭品
function c15545291.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有上级召唤的怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c15545291.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 等级不低于7且最少需要1个祭品，并检查场上是否存在满足条件的祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 选择并解放1只上级召唤的怪兽作为上级召唤的祭品
function c15545291.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有上级召唤的怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c15545291.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 从候选怪兽中选择1只作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的怪兽解放，作为上级召唤的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断上级召唤是否成功
function c15545291.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤出场上盖放的卡
function c15545291.desfilter(c)
	return c:IsFacedown()
end
-- 选择场上最多2张盖放的卡作为破坏对象
function c15545291.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c15545291.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上最多2张盖放的卡
	local g=Duel.SelectTarget(tp,c15545291.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if e:GetLabel()==1 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		-- 设置抽卡效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 过滤出与效果相关的盖放卡
function c15545291.dfilter(c,e)
	return c:IsFacedown() and c:IsRelateToEffect(e)
end
-- 执行破坏和抽卡效果
function c15545291.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c15545291.dfilter,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
	if e:GetLabel()==1 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 检查上级召唤所用祭品中是否存在地属性怪兽，若存在则设置标签为1
function c15545291.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
