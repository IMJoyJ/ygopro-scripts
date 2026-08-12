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
-- 当对方准备将怪兽召唤或特殊召唤到场上时，检查对方场上怪兽数量是否超过己方场上的怪兽数量，若超过则禁止召唤。
function c35059553.value(e,fp,rp,r)
	if rp==e:GetHandlerPlayer() or r~=LOCATION_REASON_TOFIELD then return 7 end
	-- 获取己方场上怪兽数量作为限制基准。
	local limit=Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	return limit>0 and limit or 7
end
-- 当对方准备将怪兽召唤或特殊召唤到场上时，检查对方场上怪兽数量是否超过己方场上的怪兽数量，若超过则禁止召唤。
function c35059553.sumlimit(e,c)
	local tp=e:GetHandlerPlayer()
	if c:IsControler(1-tp) then
		local mint,maxt=c:GetTributeRequirement()
		-- 获取己方场上怪兽数量作为限制基准。
		local x=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		-- 获取对方场上怪兽数量作为限制基准。
		local y=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 获取己方场上具有EFFECT_EXTRA_RELEASE效果的怪兽数量。
		local ex=Duel.GetMatchingGroupCount(Card.IsHasEffect,tp,LOCATION_MZONE,0,nil,EFFECT_EXTRA_RELEASE)
		-- 获取己方场上具有EFFECT_EXTRA_RELEASE_SUM效果的怪兽数量。
		local exs=Duel.GetMatchingGroupCount(Card.IsHasEffect,tp,LOCATION_MZONE,0,nil,EFFECT_EXTRA_RELEASE_SUM)
		if ex==0 and exs>0 then ex=1 end
		return y-maxt+ex+1 > x-ex
	else
		return false
	end
end
