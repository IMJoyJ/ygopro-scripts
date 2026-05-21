--怨邪帝ガイウス
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
-- ①：这张卡上级召唤成功的场合，以场上1张卡为对象发动。那张卡除外，给与对方1000伤害。除外的卡是暗属性怪兽卡的场合，从那控制者的手卡·卡组·额外卡组·墓地把同名卡全部除外。这张卡把暗属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
-- ●这个效果的对象可以变成2张。
function c87288189.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87288189,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c87288189.otcon)
	e1:SetOperation(c87288189.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤成功的场合，以场上1张卡为对象发动。那张卡除外，给与对方1000伤害。除外的卡是暗属性怪兽卡的场合，从那控制者的手卡·卡组·额外卡组·墓地把同名卡全部除外。这张卡把暗属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。●这个效果的对象可以变成2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87288189,1))  --"卡片除外"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c87288189.condition)
	e3:SetTarget(c87288189.target)
	e3:SetOperation(c87288189.operation)
	c:RegisterEffect(e3)
	-- 这张卡把暗属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c87288189.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤上级召唤成功的怪兽
function c87288189.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 替代上级召唤规则的条件：自身等级在7星以上、需要解放的怪兽数量在1只以下，且场上存在满足解放条件（上级召唤成功）的怪兽
function c87288189.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上所有上级召唤成功的怪兽组
	local mg=Duel.GetMatchingGroup(c87288189.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查自身等级是否在7星以上、最少解放数量是否在1只以下，且场上是否存在1只符合条件的怪兽作为祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 替代上级召唤规则的具体操作：选择并解放1只上级召唤成功的怪兽
function c87288189.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有上级召唤成功的怪兽组
	local mg=Duel.GetMatchingGroup(c87288189.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家选择1只符合条件的怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选择的怪兽作为上级召唤的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果发动条件：这张卡上级召唤成功
function c87288189.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动时的对象选择与操作信息注册：根据是否解放了暗属性怪兽，选择场上1张或最多2张卡作为对象，并注册除外和伤害的操作信息
function c87288189.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	local ct=1
	if e:GetLabel()==1 then ct=2 end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择场上1张（若解放了暗属性怪兽则最多2张）可以除外的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 注册连锁处理信息：除外选中的卡片
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
		-- 注册连锁处理信息：给与对方1000点伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
end
-- 效果处理：除外对象卡片并给予伤害，若除外的卡是暗属性怪兽，则将其控制者的手卡·卡组·额外卡组·墓地的同名卡全部除外
function c87288189.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若存在有效的对象卡片，则将其表侧表示除外，并判断是否成功除外
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 给与对方1000点伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
		-- 获取实际被操作（除外）的卡片组
		local og=Duel.GetOperatedGroup()
		local rg=Group.CreateGroup()
		local tc=og:GetFirst()
		while tc do
			if tc:IsAttribute(ATTRIBUTE_DARK) then
				-- 获取该卡片控制者的手卡、卡组、墓地、额外卡组中所有同名卡
				local sg=Duel.GetMatchingGroup(Card.IsCode,tc:GetControler(),0x53,0,nil,tc:GetCode())
				rg:Merge(sg)
			end
			tc=og:GetNext()
		end
		if rg:GetCount()>0 then
			-- 中断当前效果，使后续的同名卡除外处理不与前述除外、伤害处理同时进行
			Duel.BreakEffect()
			-- 将找到的所有同名卡表侧表示除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 检查上级召唤的祭品中是否存在暗属性怪兽，若存在则将效果e3的Label设为1，否则设为0
function c87288189.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
