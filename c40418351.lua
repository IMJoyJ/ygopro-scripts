--鎧黒竜－サイバー・ダーク・ドラゴン
-- 效果：
-- 「电子暗黑魔角」＋「电子暗黑刃翼」＋「电子暗黑龙骨」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以自己墓地1只龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值以及自己墓地的怪兽数量×100。
-- ③：这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
function c40418351.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为41230939,77625948,3019642的3只怪兽为融合素材
	aux.AddFusionProcCode3(c,41230939,77625948,3019642,true,true)
	-- ①：这张卡特殊召唤成功的场合，以自己墓地1只龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40418351,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40418351.eqtg)
	e1:SetOperation(c40418351.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值以及自己墓地的怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c40418351.atkval)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此效果为不能通过融合召唤以外的方式特殊召唤
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的龙族怪兽
function c40418351.filter(c)
	return c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 设置效果目标，选择满足条件的墓地龙族怪兽
function c40418351.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否满足位置和种族条件
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (chkc:IsControler(tp) or Duel.IsPlayerAffectedByEffect(tp,64753988)) and c40418351.filter(chkc) end
	if chk==0 then return true end
	-- 根据是否受到效果影响确定可选位置
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的墓地龙族怪兽作为目标
	local g=Duel.SelectTarget(tp,c40418351.filter,tp,LOCATION_GRAVE,loc,1,1,nil)
	-- 设置操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果处理函数，执行装备操作并注册相关效果
function c40418351.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 尝试将目标卡装备给自身，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 装备对象限制效果，确保只能装备给自身
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c40418351.eqlimit)
		tc:RegisterEffect(e1)
		-- 装备攻击力提升效果，提升值为装备怪兽的攻击力
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		-- 装备破坏代替效果，使装备怪兽在战斗破坏时代替自身被破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c40418351.repval)
		tc:RegisterEffect(e3)
	end
end
-- 装备对象限制函数，确保装备卡只能装备给自身
function c40418351.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 破坏代替函数，判断是否为战斗破坏
function c40418351.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 攻击力计算函数，计算墓地怪兽数量×100作为攻击力加成
function c40418351.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 返回墓地怪兽数量乘以100作为攻击力加成
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)*100
end
