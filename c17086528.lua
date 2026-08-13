--相生の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以自己场上1只超量怪兽和1只5星以上的怪兽为对象才能发动。那只超量怪兽的阶级直到回合结束时变成和那只5星以上的怪兽的等级数值相同。
-- ②：自己场上的卡比对方场上多的场合，这张卡的灵摆刻度变成4。
-- 【怪兽效果】
-- ①：这张卡的战斗发生的对对方的战斗伤害变成0。
-- ②：1回合1次，以这张卡以外的自己场上1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽相同。
function c17086528.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤、灵摆区发动等基础功能）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只超量怪兽和1只5星以上的怪兽为对象才能发动。那只超量怪兽的阶级直到回合结束时变成和那只5星以上的怪兽的等级数值相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c17086528.rktg)
	e2:SetOperation(c17086528.rkop)
	c:RegisterEffect(e2)
	-- ②：自己场上的卡比对方场上多的场合，这张卡的灵摆刻度变成4。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_LSCALE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c17086528.slcon)
	e3:SetValue(4)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e4)
	-- ①：这张卡的战斗发生的对对方的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
	-- ②：1回合1次，以这张卡以外的自己场上1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽相同。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCountLimit(1)
	e6:SetTarget(c17086528.atktg)
	e6:SetOperation(c17086528.atkop)
	c:RegisterEffect(e6)
end
-- 过滤候选的超量怪兽对象：表侧表示的超量怪兽，且自己场上还存在1只5星以上、等级数值与该超量怪兽阶级不同的怪兽可作为第二对象。
function c17086528.rkfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 同时检查自己场上是否存在满足条件的第二对象：表侧表示、5星以上、等级不等于该超量怪兽当前阶级的怪兽（且不能是超量怪兽本身）。
		and Duel.IsExistingTarget(c17086528.lvfilter,tp,LOCATION_MZONE,0,1,c,c:GetRank())
end
-- 过滤第二对象（等级怪兽）：表侧表示、等级5以上，且等级数值不等于作为第一对象的超量怪兽的阶级。
function c17086528.lvfilter(c,rk)
	return c:IsFaceup() and c:IsLevelAbove(5) and not c:IsLevel(rk)
end
-- 起动效果①的发动时点：检查是否存在符合条件的对象；发动时先选择自己场上的1只超量怪兽，再选择1只5星以上且等级不同的怪兽，并将超量怪兽记录在效果标签中，供处理阶段使用。
function c17086528.rktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动条件检查：自己的主要怪兽区是否存在至少1只可作为对象的超量怪兽（并且同时有符合条件的等级怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c17086528.rkfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的超量怪兽作为效果对象，并注册为连锁对象。
	local g=Duel.SelectTarget(tp,c17086528.rkfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 再次发送“请选择效果的对象”提示，用于选择第二只等级怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只5星以上且等级不等于已选超量怪兽阶级的怪兽作为第二对象，并排除第一对象，同时将其注册为连锁对象。
	Duel.SelectTarget(tp,c17086528.lvfilter,tp,LOCATION_MZONE,0,1,1,g:GetFirst(),g:GetFirst():GetRank())
end
-- 效果处理时：取得两个对象（超量怪兽和等级怪兽），若都仍合法，则为超量怪兽施加一个直到回合结束时将其阶级变为该等级怪兽等级的持续效果。
function c17086528.rkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取本次连锁发动时所选择的对象卡组（包括超量怪兽和等级怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and lc:IsRelateToEffect(e) and lc:IsFaceup() and lc:IsLevelAbove(5) then
		-- 那只超量怪兽的阶级直到回合结束时变成和那只5星以上的怪兽的等级数值相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RANK)
		e1:SetValue(lc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 灵摆效果②的发动条件：自己场上的卡数量多于对方场上的卡数量。
function c17086528.slcon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较自己场上（LOCATION_ONFIELD）卡的数量是否大于对方场上的卡数量，作为条件判定结果。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
end
-- 过滤攻击力变化对象：表侧表示、攻击力数值与本卡当前攻击力不同的自己怪兽。
function c17086528.atkfilter(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end
-- 怪兽效果②的发动时点：检查是否存在符合条件的对象；发动时选择这张卡以外的自己场上1只表侧表示且攻击力不同的怪兽作为对象。
function c17086528.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=c and c17086528.atkfilter(chkc,atk) end
	-- 效果发动条件检查：自己场上是否存在至少1只除本卡以外、表侧表示且攻击力不同的可选怪兽。
	if chk==0 then return Duel.IsExistingTarget(c17086528.atkfilter,tp,LOCATION_MZONE,0,1,c,atk) end
	-- 向玩家发送“请选择效果的对象”提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的自己怪兽作为效果对象，并注册为连锁对象。
	Duel.SelectTarget(tp,c17086528.atkfilter,tp,LOCATION_MZONE,0,1,1,c,atk)
end
-- 效果处理时：若本卡和对象怪兽都仍合法，则为这张卡赋予直到回合结束时攻击力变为对象怪兽当前攻击力的效果。
function c17086528.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁的处理对象（被选择的自己怪兽）。
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
