--御巫かみかくし
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽给自己场上1只「御巫」怪兽当作装备魔法卡使用来装备。场上有仪式怪兽卡存在的场合，可以再给与对方为自己场上的装备魔法卡数量×500伤害。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·除外状态的1只「御巫」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册卡片的两个效果：效果①为魔法卡发动效果，取对象后将对方怪兽装备给自己场上的「御巫」怪兽并可能造成伤害；效果②为墓地二速效果，除外自身后从手卡或除外区特殊召唤「御巫」怪兽。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽给自己场上1只「御巫」怪兽当作装备魔法卡使用来装备。场上有仪式怪兽卡存在的场合，可以再给与对方为自己场上的装备魔法卡数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·除外状态的1只「御巫」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置效果②的发动代价为：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义效果①对象怪兽的筛选条件：对方场上的表侧表示怪兽，且能够变更控制权（可被当作装备卡装备给我方怪兽）。
function s.filter(c,tp)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 定义装备目标「御巫」怪兽的筛选条件：我方场上的表侧表示怪兽，且卡名含有「御巫」字段。
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18d)
end
-- 效果①的发动条件与对象选择：需要魔陷区有空位、存在可选的对方怪兽和己方「御巫」怪兽；发动时选择对方场上1只表侧表示怪兽作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	if chk==0 then
		-- 获取我方魔陷区的可用空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 要求魔陷区空格数大于0，且存在满足条件的对方表侧表示怪兽可以作为对象。
		return ft>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
			-- 同时要求我方场上存在表侧表示且属于「御巫」字段的怪兽，作为装备对象。
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	-- 给玩家显示选择对象的目标提示（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果对象，并建立对象关联。
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- 定义追加伤害条件中的仪式怪兽筛选：场上存在表侧表示且原类型为仪式怪兽（原类型包含怪兽类型与仪式类型）的卡。
function s.dafilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),0x81)==0x81
end
-- 定义装备魔法卡筛选：表侧表示且类型为装备魔法卡，用于计算伤害数量。
function s.dafilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- 效果①的实际处理：将对象怪兽装备给我方场上的「御巫」怪兽；若场上有仪式怪兽且我方选择造成伤害，则按装备魔法卡数量×500给与对方伤害。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联、仍为表侧表示，且我方魔陷区有空位可装备。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的「御巫」怪兽（“请选择要装备的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从我方场上选择1只表侧表示「御巫」怪兽作为装备对象，并取选择结果中的第一张。
		local sc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		-- 若成功选择到「御巫」怪兽，则把对象怪兽作为装备魔法卡装备给该「御巫」怪兽。
		if sc and Duel.Equip(tp,tc,sc) then
			-- 那只表侧表示怪兽给自己场上1只「御巫」怪兽当作装备魔法卡使用来装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(sc)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1)
			-- 判断场上是否存在表侧表示仪式怪兽，决定是否可以追加伤害。
			if Duel.IsExistingMatchingCard(s.dafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
				-- 判断我方魔陷区是否存在表侧表示装备魔法卡，以确认可以造成伤害的数量依据。
				and Duel.IsExistingMatchingCard(s.dafilter2,tp,LOCATION_SZONE,0,1,nil)
				-- 满足追加条件时，询问玩家是否选择给与对方伤害（“是否给与对方伤害？”）。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否给与对方伤害？"
				-- 中断当前效果的处理，使后续的伤害处理与之前的装备处理视为分开的效果处理，以正确触发时点。
				Duel.BreakEffect()
				-- 计算伤害值：我方场上表侧表示装备魔法卡数量×500。
				local d=Duel.GetMatchingGroupCount(s.dafilter2,tp,LOCATION_SZONE,0,nil)*500
				-- 给对方造成计算出的效果伤害。
				Duel.Damage(1-tp,d,REASON_EFFECT)
			end
		end
	end
end
-- 定义装备限制函数：作为装备卡的怪兽仅能装备给标签记录的「御巫」怪兽。
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 定义效果②特殊召唤对象的筛选：手卡或除外状态、表侧表示、卡名属于「御巫」字段且可以被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceupEx()
end
-- 效果②的发动条件：我方主要怪兽区有空位，且手卡或除外区存在符合条件的「御巫」怪兽；并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或除外区是否存在符合条件的「御巫」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置本次效果涉及特殊召唤的操作信息，供相关卡牌效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 效果②的实际处理：若仍有怪兽区空位，从手卡或除外区选择1只「御巫」怪兽表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区有空位，否则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或除外区选择1只符合条件的「御巫」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()<=0 then return end
	-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
