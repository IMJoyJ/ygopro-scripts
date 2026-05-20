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
-- 过滤条件：自己墓地的「兽带斗神」怪兽，且在场上只能唯一存在
function c75290703.eqfilter(c,tp)
	return c:IsSetCard(0x179) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- 效果①的发动准备：进行对象选择与特殊召唤、装备操作的合法性检测
function c75290703.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c75290703.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 获取自己场上可用的魔法与陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 在发动效果的检测阶段，确认自己场上有可用的怪兽区域和魔陷区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0
		-- 确认自己墓地存在至少1只满足条件的「兽带斗神」怪兽
		and Duel.IsExistingTarget(c75290703.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if ft>3 then ft=3 end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地最多等同于空余魔陷区数量（且最多3张）的「兽带斗神」怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c75290703.eqfilter,tp,LOCATION_GRAVE,0,1,ft,nil,tp)
	-- 设置连锁信息：包含有卡片离开墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,#sg,0,0)
	-- 设置连锁信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：特殊召唤此卡，并将作为对象的怪兽当作装备卡装备给此卡
function c75290703.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自己场上有可用的怪兽区域，且此卡仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将此卡以表侧表示特殊召唤，并确认特殊召唤成功
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取仍与效果相关联的作为对象的怪兽卡组
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		-- 再次获取自己场上可用的魔法与陷阱区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<=0 then return end
		if g:GetCount()>ft then
			-- 提示玩家选择要装备的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 将目标怪兽作为装备卡装备给此卡（分步处理）
				Duel.Equip(tp,tc,c,true,true)
				-- 作为对象的怪兽当作装备卡使用给这张卡装备。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c75290703.eqlimit)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
			-- 完成装备卡装备流程，触发装备成功的时点
			Duel.EquipComplete()
		end
	end
end
-- 装备限制：只能装备给该效果的拥有者（即此卡）
function c75290703.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤条件：手牌中的「无尽机关 银星系统」，且可以被丢弃
function c75290703.cfilter(c)
	return c:IsCode(21887075) and c:IsDiscardable()
end
-- 效果②的费用：从手卡丢弃1张「无尽机关 银星系统」
function c75290703.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，确认手牌中是否存在可以丢弃的「无尽机关 银星系统」
	if chk==0 then return Duel.IsExistingMatchingCard(c75290703.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择并丢弃1张「无尽机关 银星系统」作为发动费用
	Duel.DiscardHand(tp,c75290703.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果②的发动准备：确认对方场上存在卡片，并设置破坏连锁信息
function c75290703.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，确认对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁信息：破坏对方场上的全部卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的处理：破坏对方场上的全部卡片
function c75290703.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏对方场上的全部卡片
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果③的发动条件：此卡处于装备卡状态
function c75290703.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 效果③的发动准备：确认自己场上有可用的怪兽区域，并设置特殊召唤连锁信息
function c75290703.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，确认自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的处理：特殊召唤此卡，之后将此卡原本装备的怪兽重新装备给此卡
function c75290703.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 确认此卡仍与效果相关联，将其特殊召唤成功，且原本装备的怪兽依然存在
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and tc then
		-- 中断当前效果处理，使后续的装备操作不与特殊召唤同时处理（那之后）
		Duel.BreakEffect()
		-- 将原本装备的怪兽重新作为装备卡装备给此卡
		Duel.Equip(tp,tc,c,false)
		-- 那之后，这张卡装备过的怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c75290703.eqlimit)
		tc:RegisterEffect(e1)
	end
end
