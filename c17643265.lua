--ツーヘッド・シャーク
-- 效果：
-- 这张卡召唤成功时，可以让自己场上的全部鱼族·4星怪兽的等级下降1星。这张卡在同1次的战斗阶段中可以作2次攻击。
function c17643265.initial_effect(c)
	-- 这张卡召唤成功时，可以让自己场上的全部鱼族·4星怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17643265,0))  --"等级下降"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c17643265.lvtg)
	e1:SetOperation(c17643265.lvop)
	c:RegisterEffect(e1)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上表侧表示且等级为4的鱼族怪兽，作为等级下降效果的对象判定条件。
function c17643265.filter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsRace(RACE_FISH)
end
-- 效果发动时的目标判定：若自己场上存在符合条件的鱼族·4星怪兽，则允许玩家发动该诱发选发效果。
function c17643265.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：chk==0时检索是否存在至少1张满足条件的怪兽，存在才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17643265.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：检索自己场上所有符合条件的鱼族·4星怪兽，逐只使其等级下降1星（通过注册单次效果实现）。
function c17643265.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有符合过滤条件（表侧表示·等级4·鱼族）的怪兽集合。
	local g=Duel.GetMatchingGroup(c17643265.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 让自己场上的全部鱼族·4星怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
