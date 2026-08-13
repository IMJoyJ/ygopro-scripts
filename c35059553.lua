--カイザーコロシアム
-- 效果：
-- ①：只要自己场上有怪兽存在，对方不能让要变到比那个数量多的怪兽在自身场上出现。
function c35059553.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有怪兽存在，对方不能让要变到比那个数量多的怪兽在自身场上出现。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_MAX_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(c35059553.value)
	c:RegisterEffect(e2)
	-- ①：只要自己场上有怪兽存在，对方不能让要变到比那个数量多的怪兽在自身场上出现。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(c35059553.sumlimit)
	c:RegisterEffect(e3)
	-- ①：只要自己场上有怪兽存在，对方不能让要变到比那个数量多的怪兽在自身场上出现。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_KAISER_COLOSSEUM)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	c:RegisterEffect(e4)
end
-- 作为EFFECT_MAX_MZONE的Value函数，计算对方场上可存在的怪兽数量上限：若本次移动并非要上场或并非对方玩家的操作则返回7（不限制）；否则返回我方场上怪兽数量，若为0则同样返回7。
function c35059553.value(e,fp,rp,r)
	if rp==e:GetHandlerPlayer() or r~=LOCATION_REASON_TOFIELD then return 7 end
	-- 获取我方场上当前的怪兽数量，作为对方场上怪兽数量不能超过的限制数值。
	local limit=Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	return limit>0 and limit or 7
end
-- 作为EFFECT_UNRELEASABLE_SUM的Value函数，判断对方怪兽是否不能作为上级召唤的解放。通过比较对方解放前后场上怪兽数量以及可用的额外解放数量，阻止对方通过解放召唤使场上怪兽数量超过我方怪兽数量，从而辅助实现皇帝斗技场的限制。
function c35059553.sumlimit(e,c)
	local tp=e:GetHandlerPlayer()
	if c:IsControler(1-tp) then
		local mint,maxt=c:GetTributeRequirement()
		-- 获取我方场上当前的怪兽数量x，用于后续数量限制判断。
		local x=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		-- 获取对方场上当前的怪兽数量y，用于后续解放后数量是否超限的判断。
		local y=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 统计我方场上拥有EFFECT_EXTRA_RELEASE效果的怪兽数量ex，这些怪兽可被对方作为额外解放使用，因此需要纳入数量计算。
		local ex=Duel.GetMatchingGroupCount(Card.IsHasEffect,tp,LOCATION_MZONE,0,nil,EFFECT_EXTRA_RELEASE)
		-- 统计我方场上拥有EFFECT_EXTRA_RELEASE_SUM效果的怪兽数量exs；若没有EFFECT_EXTRA_RELEASE但有EFFECT_EXTRA_RELEASE_SUM，则视为有1个额外解放可被使用，用于补足解放数量限制的计算。
		local exs=Duel.GetMatchingGroupCount(Card.IsHasEffect,tp,LOCATION_MZONE,0,nil,EFFECT_EXTRA_RELEASE_SUM)
		if ex==0 and exs>0 then ex=1 end
		return y-maxt+ex+1 > x-ex
	else
		return false
	end
end
