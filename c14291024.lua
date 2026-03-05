--オプション
-- 效果：
-- 这张卡不能通常召唤。自己场上有「超时空战斗机 V形蛇」表侧表示存在的场合可以特殊召唤。这张卡特殊召唤的场合，必须选择自己场上表侧表示存在的1只「超时空战斗机 V形蛇」。这张卡的攻击力·守备力一直和选择的怪兽相同。选择的怪兽不在场上表侧表示存在时，这张卡破坏。
function c14291024.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有「超时空战斗机 V形蛇」表侧表示存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14291024.spcon)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的场合，必须选择自己场上表侧表示存在的1只「超时空战斗机 V形蛇」。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetOperation(c14291024.spcost)
	c:RegisterEffect(e0)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e0:SetLabelObject(g)
	-- 这张卡的攻击力·守备力一直和选择的怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c14291024.splimit)
	c:RegisterEffect(e2)
	-- 选择的怪兽不在场上表侧表示存在时，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c14291024.tgop)
	e3:SetLabelObject(e0)
	c:RegisterEffect(e3)
	-- 这张卡不能通常召唤。自己场上有「超时空战斗机 V形蛇」表侧表示存在的场合可以特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE,EFFECT_FLAG2_OPTION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c14291024.adcon)
	e4:SetValue(c14291024.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e5:SetValue(c14291024.defval)
	c:RegisterEffect(e5)
	-- 选择的怪兽不在场上表侧表示存在时，这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c14291024.sdcon)
	c:RegisterEffect(e6)
end
-- 用于筛选场上表侧表示存在的「超时空战斗机 V形蛇」
function c14291024.filter(c)
	return c:IsFaceup() and c:IsCode(10992251)
end
-- 判断特殊召唤条件是否满足，需满足场上存在「超时空战斗机 V形蛇」且有空场
function c14291024.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家场上是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查当前玩家场上是否存在至少1只「超时空战斗机 V形蛇」
		and Duel.IsExistingMatchingCard(c14291024.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤时的处理函数，用于选择目标「超时空战斗机 V形蛇」
function c14291024.spcost(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Clear()
	-- 提示玩家选择目标「超时空战斗机 V形蛇」
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(14291024,0))  --"请选择1只「超时空战斗机 V形蛇」"
	-- 从玩家场上选择1只「超时空战斗机 V形蛇」作为目标
	local g=Duel.SelectMatchingCard(tp,c14291024.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选中的目标怪兽
		Duel.HintSelection(g)
		e:GetLabelObject():Merge(g)
	end
end
-- 限制特殊召唤条件，确保场上存在「超时空战斗机 V形蛇」
function c14291024.splimit(e,se,sp,st,pos,top)
	-- 检查特殊召唤时是否满足条件，即场上存在「超时空战斗机 V形蛇」
	return Duel.IsExistingMatchingCard(c14291024.filter,sp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤成功后的处理函数，用于设置目标怪兽
function c14291024.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject():GetLabelObject()
	if g:GetCount()>0 then
		c:SetCardTarget(g:GetFirst())
		c:RegisterFlagEffect(14291024,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 判断是否已选择目标怪兽
function c14291024.adcon(e)
	return e:GetHandler():GetFirstCardTarget()~=nil
end
-- 返回目标怪兽的攻击力
function c14291024.atkval(e,c)
	return c:GetFirstCardTarget():GetAttack()
end
-- 返回目标怪兽的守备力
function c14291024.defval(e,c)
	return c:GetFirstCardTarget():GetDefense()
end
-- 判断是否满足自我破坏条件，即目标怪兽不存在且已记录flag
function c14291024.sdcon(e)
	return e:GetHandler():GetFirstCardTarget()==nil and e:GetHandler():GetFlagEffect(14291024)~=0
end
