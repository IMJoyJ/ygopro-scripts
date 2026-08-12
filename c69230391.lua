--爆炎帝テスタロス
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
-- ①：这张卡上级召唤的场合发动。把对方手卡确认，选那之内的1张丢弃。丢弃的卡是怪兽的场合，给与对方那只怪兽的等级×200伤害。这张卡把炎属性怪兽解放作上级召唤的场合，那个时候的效果加上以下效果。
-- ●给与对方1000伤害。
function c69230391.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69230391,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c69230391.otcon)
	e1:SetOperation(c69230391.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤的场合发动。把对方手卡确认，选那之内的1张丢弃。丢弃的卡是怪兽的场合，给与对方那只怪兽的等级×200伤害。这张卡把炎属性怪兽解放作上级召唤的场合，那个时候的效果加上以下效果。●给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69230391,1))
	e3:SetCategory(CATEGORY_HANDES_OPPO+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c69230391.condition)
	e3:SetTarget(c69230391.target)
	e3:SetOperation(c69230391.operation)
	c:RegisterEffect(e3)
	-- 这张卡把炎属性怪兽解放作上级召唤的场合，那个时候的效果加上以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c69230391.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤条件：是否为上级召唤成功的怪兽
function c69230391.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 上级召唤规则效果的适用条件
function c69230391.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有上级召唤成功的怪兽作为解放候选
	local mg=Duel.GetMatchingGroup(c69230391.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判断自身等级是否在7星以上、最少解放数量是否不大于1，且场上是否存在满足条件的解放怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤规则效果的具体解放处理
function c69230391.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有上级召唤成功的怪兽
	local mg=Duel.GetMatchingGroup(c69230391.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家选择1只上级召唤成功的怪兽作为解放素材
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果发动条件：此卡上级召唤成功
function c69230391.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动时的目标确认与操作信息设置
function c69230391.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	if e:GetLabel()==1 then
		-- 若满足炎属性解放条件，追加设置操作信息：给与对方1000点伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
end
-- 效果处理：确认对方手卡并丢弃，根据丢弃卡片种类及解放素材追加伤害
function c69230391.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的所有手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 给己方玩家确认对方的所有手牌
		Duel.ConfirmCards(tp,g)
		-- 提示己方玩家选择要丢弃的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local hg=g:Select(tp,1,1,nil)
		-- 将选中的对方手牌因效果丢弃送去墓地
		Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)
		-- 洗切对方的手牌
		Duel.ShuffleHand(1-tp)
		local tc=hg:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			-- 给与对方丢弃怪兽等级×200的伤害
			Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
		end
	end
	if e:GetLabel()==1 then
		-- 中断当前效果处理，使后续伤害不与前面的效果同时处理
		Duel.BreakEffect()
		-- 给与对方1000点伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
-- 检查上级召唤的素材中是否存在炎属性怪兽，并为效果注册标记值
function c69230391.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
