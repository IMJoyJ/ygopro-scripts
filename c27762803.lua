--ナチュル・ビートル
-- 效果：
-- 每次魔法卡发动，这张卡的原本攻击力·守备力交换。
function c27762803.initial_effect(c)
	-- 每次魔法卡发动，这张卡的原本攻击力·守备力交换。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetOperation(c27762803.adop)
	c:RegisterEffect(e1)
	-- 每次魔法卡发动，这张卡的原本攻击力·守备力交换。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c27762803.con)
	c:RegisterEffect(e2)
end
-- 判断当前卡片是否已注册标识效果，用于控制交换效果的触发条件
function c27762803.con(e)
	return e:GetHandler():GetFlagEffect(27762803)~=0
end
-- 当有魔法卡发动时，注册或重置标识效果以触发攻击力与守备力的交换
function c27762803.adop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		if e:GetHandler():GetFlagEffect(27762803)==0 then
			e:GetHandler():RegisterFlagEffect(27762803,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		else
			e:GetHandler():ResetFlagEffect(27762803)
		end
	end
end
