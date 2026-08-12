--紅恋の麗傑－ブラダマンテ
-- 效果：
-- 这个卡名在规则上也当作「焰圣骑士」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以自己场上1只战士族怪兽为对象才能发动。从卡组选1张那只怪兽可以装备的装备魔法卡给那只怪兽装备。
-- ②：没有装备卡装备的这张卡被和对方怪兽的战斗破坏送去墓地时才能发动。这张卡特殊召唤，那只对方场上的怪兽当作装备卡使用给这张卡装备。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手卡发动起动效果给战士族怪兽装备卡组的装备魔法）、离场前检测是否装备有装备卡、②效果（无装备卡被战破送墓时特召并装备对方怪兽）。
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以自己场上1只战士族怪兽为对象才能发动。从卡组选1张那只怪兽可以装备的装备魔法卡给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- 没有装备卡装备的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.checkop)
	c:RegisterEffect(e2)
	-- ②：没有装备卡装备的这张卡被和对方怪兽的战斗破坏送去墓地时才能发动。这张卡特殊召唤，那只对方场上的怪兽当作装备卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
end
-- ①效果的发动代价：检查并执行将自身从手卡丢弃。
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤自己场上表侧表示的战士族怪兽，且卡组中存在可装备给该怪兽的装备魔法卡。
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
		-- 检查卡组中是否存在至少1张可以装备给该怪兽的装备魔法卡。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
-- 过滤卡组中符合装备给目标怪兽条件、且在场上唯一存在、未被限制使用的装备魔法卡。
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ①效果的发动准备：检查魔陷区空位并选择自己场上1只战士族怪兽作为对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	-- 检查自己场上的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在符合条件的战士族怪兽作为效果对象。
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只战士族怪兽作为效果的对象。
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- ①效果的效果处理：从卡组选择1张装备魔法卡装备给作为对象的战士族怪兽。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的魔法与陷阱区域，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取作为效果对象的战士族怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组选择1张可以装备给目标怪兽的装备魔法卡。
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
		if g:GetCount()>0 then
			-- 将选中的装备魔法卡装备给目标怪兽。
			Duel.Equip(tp,g:GetFirst(),tc)
		end
	end
end
-- 离场前检测：若这张卡没有装备卡装备，则将标记值设为1，否则设为0。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetEquipGroup():GetCount()==0 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ②效果的发动条件：自身在没有装备卡的状态下被对方怪兽战斗破坏送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return e:GetLabel()==1 and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and rp==1-tp
		and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsControler(1-tp)
end
-- ②效果的发动准备：检查怪兽区和魔陷区空位，确认自身可特召且对方怪兽可转移控制权。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=e:GetLabelObject()
	-- 检查自己场上的怪兽区域和魔法与陷阱区域是否都有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and bc:IsAbleToChangeControler() end
	-- 将进行战斗的对方怪兽设为效果处理的对象。
	Duel.SetTargetCard(bc)
	-- 设置连锁信息：此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的效果处理：将自身特殊召唤，并将进行战斗的对方怪兽作为装备卡装备给自身。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关联，且自己场上是否有可用的怪兽区域。
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 将自身以表侧表示特殊召唤，并检查是否特殊召唤成功。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取作为效果对象的对方怪兽。
		local bc=Duel.GetFirstTarget()
		if bc:IsRelateToEffect(e) and bc:IsRelateToBattle() and bc:IsControler(1-tp)
			-- 将对方怪兽作为装备卡装备给自身。
			and Duel.Equip(tp,bc,c,false) then
			-- 当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			bc:RegisterEffect(e1)
		end
	end
end
-- 装备限制：该卡只能装备给此效果的拥有者（即这张卡）。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
