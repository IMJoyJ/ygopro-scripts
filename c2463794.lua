--刻まれし魔の鎮魂棺
-- 效果：
-- 恶魔族·光属性怪兽1只
-- 自己对「刻魔的镇魂棺」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放才能发动。从手卡·卡组把1只「刻魔」怪兽特殊召唤。
-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作攻击力上升600的装备魔法卡使用给那只自己怪兽装备。
local s,id,o=GetID()
-- 初始化效果：设置自己对「刻魔的镇魂棺」1回合只能有1次特殊召唤，添加连接召唤手续（恶魔族·光属性怪兽1只），允许苏生限制，并注册①的诱发即时效果与②的起动效果（那个②的效果1回合只能使用1次）。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 为这张卡添加连接召唤手续：素材为1只恶魔族·光属性怪兽（对应“恶魔族·光属性怪兽1只”）。
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，把这张卡解放才能发动。从手卡·卡组把1只「刻魔」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作攻击力上升600的装备魔法卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：要求怪兽为恶魔族且光属性。
function s.mfilter(c)
	return c:IsLinkRace(RACE_FIEND) and c:IsLinkAttribute(ATTRIBUTE_LIGHT)
end
-- ①效果的发动条件函数：限定只能在自己·对方的主要阶段发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2，用于判定①的发动时点。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的代价：解放自身；代价检查确认自身可解放，且解放后自己场上仍有空余怪兽区。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查：自身必须可解放，且解放后场上仍有可用的怪兽区域。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行代价：将这张卡解放（REASON_COST）。
	Duel.Release(c,REASON_COST)
end
-- 特殊召唤的过滤函数：卡名含有「刻魔」字段，且能够被特殊召唤。
function s.filter(c,e,tp)
	return c:IsSetCard(0x1b0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标处理：确认手卡·卡组中存在可特殊召唤的「刻魔」怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1张手卡·卡组中的「刻魔」怪兽可以特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ①效果处理：从手卡·卡组选择1只「刻魔」怪兽，以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否有空余的怪兽区，没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择框，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 实际选择手卡·卡组中1张符合条件的「刻魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②装备对象的过滤函数：对象必须是表侧表示、恶魔族、光属性且不是连接怪兽。
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsType(TYPE_LINK)
end
-- ②效果的发动目标函数：校验已选对象的合法性，并确认自己场上有符合条件的对象且魔陷区有空位。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 发动条件检查：自己魔陷区存在可用的区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且场上存在至少1只可成为对象的恶魔族·光属性非连接怪兽。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择框，提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的怪兽作为装备对象（取对象效果）。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：这次连锁包含将自己装备给对象怪兽的装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：这张卡将从墓地/场上离开并装备，记录离开墓地的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡作为装备魔法卡装备给对象怪兽，并赋予攻击力上升600；若条件不满足则送去墓地。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) then
		-- 装备成功前的校验：若魔陷区已满、对象变为里侧、对象失去联系、控制权转移或不在怪兽区，则进入失败分支。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or not tc:IsLocation(LOCATION_MZONE) then
			-- 因装备条件不满足，将这张卡以效果原因送去墓地。
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		-- 尝试将这张卡作为装备卡装备给对象；若装备失败则中止处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 当作装备魔法卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力上升600。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(600)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制判定：这张卡只能装备给标签记录的那只对象怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
