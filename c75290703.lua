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
-- 过滤墓地中表侧表示的且可以在场上唯一存在的「兽带斗神」怪兽
function c75290703.eqfilter(c,tp)
	return c:IsSetCard(0x179) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- 特殊召唤并装备墓地怪兽效果的发动条件检测与靶向选择对象
function c75290703.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c75290703.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 获取己方魔法与陷阱区域的空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 若为检测阶段，则判断己方主要怪兽区域有空位且魔法与陷阱区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0
		-- 并且墓地中存在满足过滤条件的「兽带斗神」怪兽
		and Duel.IsExistingTarget(c75290703.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if ft>3 then ft=3 end
	-- 提示玩家选择要进行装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择墓地中满足条件的「兽带斗神」怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c75290703.eqfilter,tp,LOCATION_GRAVE,0,1,ft,nil,tp)
	-- 设置效果处理的分类为将选中的卡片离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,#sg,0,0)
	-- 设置效果处理的分类为特殊召唤此卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤并装备效果处理，将此卡特殊召唤并将选中的墓地怪兽作为装备卡装备给此卡
function c75290703.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断己方主要怪兽区域是否有空位，且此卡依然与效果相关
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 并且此卡成功特殊召唤到场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前效果的对象卡中依然与效果相关的卡片组
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		-- 获取己方魔法与陷阱区域的空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<=0 then return end
		if g:GetCount()>ft then
			-- 提示玩家选择要进行装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 将目标怪兽作为装备卡装备给此卡
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
			-- 完成装备卡装备流程
			Duel.EquipComplete()
		end
	end
end
-- 限制装备卡只能装备给效果的发动者（此卡）
function c75290703.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤手牌中可以丢弃的「无尽机关 银星系统」
function c75290703.cfilter(c)
	return c:IsCode(21887075) and c:IsDiscardable()
end
-- 破坏对方全场卡效果的发动代价，丢弃1张「无尽机关 银星系统」
function c75290703.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则判断手牌中是否存在可用于丢弃的「无尽机关 银星系统」
	if chk==0 then return Duel.IsExistingMatchingCard(c75290703.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将手牌中1张「无尽机关 银星系统」丢弃送去墓地作为代价
	Duel.DiscardHand(tp,c75290703.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 破坏效果的发动条件检测与目标卡片获取
function c75290703.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则判断对方场上是否存在任何卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示此效果已被选择发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理的分类为破坏对方场上所有卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果处理，破坏对方场上的全部卡片
function c75290703.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将获取的卡片全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断此卡当前是否有装备对象怪兽
function c75290703.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 自身特殊召唤效果的发动条件检测
function c75290703.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则判断主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的分类为将此卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤自身效果处理，将此卡特殊召唤并把此卡原本的装备怪兽反过来装备给此卡
function c75290703.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 如果此卡依然有效且特殊召唤成功，且存在其原本装备的怪兽
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc then
		-- 中断当前效果处理，使后续的装备步骤与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 将该怪兽作为装备卡装备给特殊召唤上场的此卡
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
