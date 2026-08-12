--賢瑞官カルダーン
-- 效果：
-- ①：这张卡召唤时才能发动。从自己的手卡·墓地把1张永续陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ②：这张卡被送去墓地的场合才能发动。直到下个回合的结束时，自己场上的表侧表示的陷阱卡不会被对方的效果破坏。
function c86605515.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从自己的手卡·墓地把1张永续陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86605515,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c86605515.settg)
	e1:SetOperation(c86605515.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。直到下个回合的结束时，自己场上的表侧表示的陷阱卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86605515,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c86605515.indtg)
	e2:SetOperation(c86605515.indop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡或墓地中可以盖放的永续陷阱卡
function c86605515.setfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 效果①的发动准备，检查自己手卡或墓地是否存在可盖放的永续陷阱卡
function c86605515.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己手卡或墓地是否存在至少1张满足条件的永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86605515.setfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
end
-- 效果①的效果处理，从手卡或墓地选择1张永续陷阱卡在场上盖放，并使其在盖放的回合也能发动
function c86605515.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从手卡或墓地选择1张满足条件的永续陷阱卡（受墓地相关效果影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86605515.setfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选中的卡片在自己场上盖放
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(86605515,2))  --"适用「贤瑞官 卡丹」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动准备，检查本回合是否尚未适用过该效果
function c86605515.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查当前是否已注册过该效果的标识，以确保效果不会重复适用
	if chk==0 then return Duel.GetFlagEffect(tp,86605515)==0 end
end
-- 效果②的效果处理，注册一个直到下个回合结束时适用的全局效果，使自己场上的陷阱卡获得效果破坏抗性
function c86605515.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下个回合的结束时，自己场上的表侧表示的陷阱卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置抗性效果的影响对象为陷阱卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TRAP))
	-- 设置抗性类型为不会被对方的效果破坏
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 在全局环境中注册该抗性效果
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个持续2个回合（直到下个回合结束）的标识效果，用于限制效果的重复发动
	Duel.RegisterFlagEffect(tp,86605515,RESET_PHASE+PHASE_END,0,2)
end
