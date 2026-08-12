--黄金狂エルドリッチ
-- 效果：
-- 「黄金国巫妖」怪兽＋5星以上的不死族怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，卡名当作「黄金卿 黄金国巫妖」使用。
-- ②：场上的这张卡不会被战斗·效果破坏。
-- ③：把自己场上1只不死族怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。那只怪兽直到回合结束时不能攻击，不能把效果发动。
function c74889525.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「黄金国巫妖」怪兽和5星以上的不死族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1142),c74889525.matfilter,true)
	-- 设置这张卡在怪兽区域存在时，卡名当作「黄金卿 黄金国巫妖」使用
	aux.EnableChangeCode(c,95440946)
	-- ②：场上的这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ③：把自己场上1只不死族怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。那只怪兽直到回合结束时不能攻击，不能把效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74889525,0))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,74889525)
	e4:SetCost(c74889525.ctcost)
	e4:SetTarget(c74889525.cttg)
	e4:SetOperation(c74889525.ctop)
	c:RegisterEffect(e4)
end
-- 过滤融合素材中5星以上的不死族怪兽
function c74889525.matfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE)
end
-- 效果③的发动代价处理函数，标记需要检测并执行解放代价
function c74889525.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤可解放的不死族怪兽，需满足解放后有可用怪兽区域且对方场上有可夺取控制权的对象
function c74889525.rfilter(c,tp)
	-- 过滤自己场上（或表侧表示）的不死族怪兽，且该卡解放后能使自己场上留有放置夺取控制权怪兽的空位
	return c:IsRace(RACE_ZOMBIE) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在至少1只可夺取控制权的表侧表示怪兽（排除自身）
		and Duel.IsExistingTarget(c74889525.ctfilter,tp,0,LOCATION_MZONE,1,c)
end
-- 过滤可夺取控制权的对象：对方场上表侧表示且可以改变控制权的怪兽
function c74889525.ctfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 效果③的发动准备函数，处理解放代价的检测与执行，并选择对方场上1只表侧表示怪兽作为效果对象
function c74889525.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c74889525.ctfilter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在至少1只满足解放条件的不死族怪兽
			return Duel.CheckReleaseGroup(tp,c74889525.rfilter,1,nil,tp)
		else
			-- 检查对方场上是否存在至少1只可作为对象的表侧表示怪兽
			return Duel.IsExistingTarget(c74889525.ctfilter,tp,0,LOCATION_MZONE,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 玩家选择1只满足解放条件的不死族怪兽
		local sg=Duel.SelectReleaseGroup(tp,c74889525.rfilter,1,1,nil,tp)
		-- 将选择的怪兽解放作为发动的代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74889525.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为“改变1只怪兽的控制权”
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果③的效果处理函数，获取控制权并施加不能攻击、不能发动效果的限制
function c74889525.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于场上，则尝试将其控制权转移给发动效果的玩家
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)>0 then
		-- 那只怪兽直到回合结束时不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		tc:RegisterEffect(e2)
	end
end
