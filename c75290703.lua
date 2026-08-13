--セリオンズ・イレギュラー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己墓地最多3只「兽带斗神」怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：从手卡丢弃1张「无尽机关 银星系统」才能发动。对方场上的卡全部破坏。
-- ③：这张卡装备中的场合才能发动。这张卡特殊召唤。那之后，这张卡装备过的怪兽当作装备卡使用给这张卡装备。
function c75290703.initial_effect(c)
	-- ①：以自己墓地最多3只「兽带斗神」怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75290703,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,75290703)
	e1:SetTarget(c75290703.sptg1)
	e1:SetOperation(c75290703.spop1)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1张「无尽机关 银星系统」才能发动。对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75290703,1))  --"对方场上的卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,75290704)
	e2:SetCost(c75290703.descost)
	e2:SetTarget(c75290703.destg)
	e2:SetOperation(c75290703.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡装备中的场合才能发动。这张卡特殊召唤。那之后，这张卡装备过的怪兽当作装备卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75290703,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,75290705)
	e3:SetCondition(c75290703.spcon2)
	e3:SetTarget(c75290703.sptg2)
	e3:SetOperation(c75290703.spop2)
	c:RegisterEffect(e3)
end
-- 装备对象的筛选条件：是「兽带斗神」怪兽，且在自己场上不存在同名卡（满足装备魔陷区的唯一性要求）。
function c75290703.eqfilter(c,tp)
	return c:IsSetCard(0x179) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①效果的目标处理：先确认可装备的合法对象在墓地，然后检查发动条件（怪兽区和魔陷区均有空格、墓地存在可装备的「兽带斗神」怪兽、这张卡可以特殊召唤）。
function c75290703.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c75290703.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 获取自己魔法与陷阱区域当前可用的空位数，作为可装备数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 效果可发动性检查：自己的主要怪兽区域和魔法与陷阱区域都必须至少有1个空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0
		-- 效果可发动性检查：确认自己墓地存在至少1只可以成为效果对象的「兽带斗神」怪兽。
		and Duel.IsExistingTarget(c75290703.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if ft>3 then ft=3 end
	-- 向玩家发送「请选择要装备的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 以自己墓地的1～ft只「兽带斗神」怪兽为对象（数量上限为魔陷区空格数），并设为效果对象。
	local sg=Duel.SelectTarget(tp,c75290703.eqfilter,tp,LOCATION_GRAVE,0,1,ft,nil,tp)
	-- 设置操作信息：本次连锁涉及让墓地的对象卡离开墓地（用于王家长眠之谷等效果的检测）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,#sg,0,0)
	-- 设置操作信息：本次连锁将把手卡的这张卡特殊召唤1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：这张卡从手卡特殊召唤成功时，把作为对象的「兽带斗神」怪兽当作装备卡使用给这张卡装备，并给它们附加只能装备给这张卡的装备限制。
function c75290703.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自己的主要怪兽区域有空格，且这张卡仍是当前连锁的效果处理对象。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡以表侧表示特殊召唤到自己场上，并确认特殊召唤成功。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得当前连锁的对象卡片组，过滤出仍与效果相关联的卡。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		-- 获取自己魔法与陷阱区域当前可用的空位数，决定实际能装备的怪兽数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<=0 then return end
		if g:GetCount()>ft then
			-- 当对象数量超过魔陷区空格数时，提示玩家选择要装备的卡，从中选出ft只。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 把对象怪兽以装备卡的形式装备到这张卡上（分步装备处理）。
				Duel.Equip(tp,tc,c,true,true)
				-- 作为对象的怪兽当作装备卡使用给这张卡装备（装备限制：只能给这张卡装备）。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c75290703.eqlimit)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
			-- 完成分步装备流程，触发装备完成的相关时点。
			Duel.EquipComplete()
		end
	end
end
-- 装备限制条件：该装备卡只能装备给这张卡本身（即只能给「兽带斗神·非正规轩辕十四」装备）。
function c75290703.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 作为cost丢弃的手卡的筛选条件：是「无尽机关 银星系统」且可以被丢弃。
function c75290703.cfilter(c)
	return c:IsCode(21887075) and c:IsDiscardable()
end
-- ②效果的cost处理：确认手卡存在可丢弃的「无尽机关 银星系统」，并将其丢弃1张作为发动代价。
function c75290703.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认自己手卡存在至少1张可丢弃的「无尽机关 银星系统」。
	if chk==0 then return Duel.IsExistingMatchingCard(c75290703.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择1张「无尽机关 银星系统」从手卡丢弃，作为效果发动的代价。
	Duel.DiscardHand(tp,c75290703.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的目标处理：检查对方场上存在卡即可发动，设置操作信息为将对方场上的卡全部破坏。
function c75290703.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果可发动性检查：确认对方场上存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示我方选择了什么效果（显示效果描述「对方场上的卡全部破坏」）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 取得对方场上全部卡作为预计要破坏的卡组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次连锁将破坏对方场上全部卡，数量为对方场上卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果的处理：把对方场上的卡全部破坏。
function c75290703.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得对方场上当前的全部卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因将对方场上的卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡作为装备卡装备中的场合（存在被这张卡装备的怪兽）。
function c75290703.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- ③效果的目标处理：确认自己主要怪兽区域有空格且这张卡可以特殊召唤。
function c75290703.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果可发动性检查：自己的主要怪兽区域必须至少有1个空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将把装备中的这张卡特殊召唤1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的处理：这张卡特殊召唤成功时，中断处理时点，把那之后把这张卡装备过的怪兽当作装备卡使用给这张卡装备，并附加只能装备给这张卡的装备限制。
function c75290703.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 确认这张卡仍与效果关联且特殊召唤成功，并且存在这张卡装备过的怪兽。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc then
		-- 中断当前效果处理，使之后的装备处理视为不同时处理（对应原文的「那之后」）。
		Duel.BreakEffect()
		-- 把这张卡装备过的怪兽以装备卡的形式装备到这张卡上（保持其原表示形式）。
		Duel.Equip(tp,tc,c,false)
		-- 那之后，这张卡装备过的怪兽当作装备卡使用给这张卡装备（装备限制：只能给这张卡装备）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c75290703.eqlimit)
		tc:RegisterEffect(e1)
	end
end
