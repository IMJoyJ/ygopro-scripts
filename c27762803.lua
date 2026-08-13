--ナチュル・ビートル
-- 效果：
-- 每次魔法卡发动，这张卡的原本攻击力·守备力交换。
function c27762803.initial_effect(c)
	-- 每次魔法卡发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetOperation(c27762803.adop)
	c:RegisterEffect(e1)
	-- 这张卡的原本攻击力·守备力交换
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c27762803.con)
	c:RegisterEffect(e2)
end
-- 作为“原本攻守交换”效果的适用条件：仅当此卡带有27762803标记时，交换效果才生效
function c27762803.con(e)
	return e:GetHandler():GetFlagEffect(27762803)~=0
end
-- 连锁处理结束时，若刚处理的连锁是魔法卡的发动，则翻转此卡的交换状态标记：无标记则注册标记使交换效果生效，有标记则清除标记使交换效果恢复，从而实现每次魔法卡发动都交换一次原本攻守
function c27762803.adop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		if e:GetHandler():GetFlagEffect(27762803)==0 then
			e:GetHandler():RegisterFlagEffect(27762803,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		else
			e:GetHandler():ResetFlagEffect(27762803)
		end
	end
end
