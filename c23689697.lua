--凍氷帝メビウス
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。这张卡上级召唤成功时，可以选择场上最多3张魔法·陷阱卡破坏。这张卡把水属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。
-- ●对方不能对应这个效果的发动把选择的卡发动。
function c23689697.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23689697,0))  --"把1只上级召唤的怪兽解放进行上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c23689697.otcon)
	e1:SetOperation(c23689697.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 这张卡上级召唤成功时，可以选择场上最多3张魔法·陷阱卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23689697,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c23689697.descon)
	e3:SetTarget(c23689697.destg)
	e3:SetOperation(c23689697.desop)
	c:RegisterEffect(e3)
	-- 这张卡把水属性怪兽解放作上级召唤成功的场合，那个时候的效果加上以下效果。●对方不能对应这个效果的发动把选择的卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c23689697.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤出场上所有上级召唤的怪兽
function c23689697.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 判断是否满足上级召唤条件：等级不低于7，最少需要祭品1只，且场上存在满足条件的祭品
function c23689697.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有上级召唤的怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c23689697.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 等级不低于7且最少需要祭品1只，且场上存在满足条件的祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 选择并解放1只上级召唤的怪兽作为上级召唤的祭品
function c23689697.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有上级召唤的怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c23689697.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 从候选怪兽中选择1只作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的祭品怪兽解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断上级召唤是否为上级召唤类型
function c23689697.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤出魔法·陷阱卡
function c23689697.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择场上最多3张魔法·陷阱卡作为破坏对象
function c23689697.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c23689697.filter(chkc) end
	-- 判断是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c23689697.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上最多3张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c23689697.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if e:GetLabel()==1 then
		-- 设置连锁限制，使对方不能对应此效果发动选择的卡
		Duel.SetChainLimit(c23689697.chlimit)
	end
end
-- 连锁限制函数，防止对方对效果发动进行连锁
function c23689697.chlimit(e,ep,tp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return tp==ep or not g:IsContains(e:GetHandler())
end
-- 执行破坏效果，将目标卡破坏
function c23689697.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组中与效果相关的卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 检查上级召唤时是否使用了水属性怪兽作为祭品，若使用则设置标签为1
function c23689697.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
