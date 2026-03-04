--タイガードラゴン
-- 效果：
-- 把龙族怪兽解放对这张卡的上级召唤成功时，可以把对方的魔法与陷阱卡区域盖放的最多2张卡破坏。
function c10097168.initial_effect(c)
	-- 可以把对方的魔法与陷阱卡区域盖放的最多2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10097168,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c10097168.condition)
	e1:SetTarget(c10097168.target)
	e1:SetOperation(c10097168.operation)
	c:RegisterEffect(e1)
	-- 把龙族怪兽解放
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c10097168.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查解放的素材中是否有龙族怪兽
function c10097168.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsRace,1,nil,RACE_DRAGON) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查召唤类型是否为上级召唤且用龙族怪兽解放
function c10097168.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 筛选对方盖放的魔法陷阱卡（排除场地区）
function c10097168.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 处理效果发动时的目标选择
function c10097168.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少一张盖放的魔法陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c10097168.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 向玩家发送选择提示，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 玩家选择最多2张对方盖放的魔法陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c10097168.filter,tp,0,LOCATION_SZONE,1,2,nil)
	-- 设置操作信息，表明效果处理时将破坏所选卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 筛选与效果相关的目标卡片（在效果处理时仍有效）
function c10097168.dfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFacedown()
end
-- 执行效果，破坏所选卡片
function c10097168.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的效果对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(c10097168.dfilter,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因破坏卡片组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
