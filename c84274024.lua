--ペンデュラム・ディメンション
-- 效果：
-- ①：这张卡已在魔法与陷阱区域存在的状态，自己用灵摆怪兽为素材对以下怪兽的特殊召唤成功的场合才能发动。这个回合，自己的「灵摆次元」的效果不能有相同效果适用。
-- ●融合：从卡组把原本等级和那只融合怪兽相同的1只怪兽效果无效守备表示特殊召唤。
-- ●同调：从卡组把1张「融合」加入手卡。
-- ●超量：从卡组把持有那只超量怪兽的阶级数值以下的等级的1只调整加入手卡或特殊召唤。
function c84274024.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡已在魔法与陷阱区域存在的状态，自己用灵摆怪兽为素材对以下怪兽的特殊召唤成功的场合才能发动。这个回合，自己的「灵摆次元」的效果不能有相同效果适用。●融合：从卡组把原本等级和那只融合怪兽相同的1只怪兽效果无效守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84274024,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c84274024.effcon)
	e2:SetTarget(c84274024.sptg)
	e2:SetOperation(c84274024.spop)
	e2:SetLabel(TYPE_FUSION)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(84274024,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetTarget(c84274024.thtg1)
	e3:SetOperation(c84274024.thop1)
	e3:SetLabel(TYPE_SYNCHRO)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(84274024,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetTarget(c84274024.thtg2)
	e4:SetOperation(c84274024.thop2)
	e4:SetLabel(TYPE_XYZ)
	c:RegisterEffect(e4)
	if not c84274024.global_check then
		c84274024.global_check=true
		-- 自己用灵摆怪兽为素材对以下怪兽的特殊召唤成功的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c84274024.valcheck)
		-- 注册全局环境效果，用于检查怪兽特殊召唤时是否使用了灵摆怪兽作为素材
		Duel.RegisterEffect(ge1,0)
	end
end
-- 材质检查函数，若融合/同调/超量怪兽使用灵摆怪兽作为素材进行特殊召唤，则给该怪兽注册一个标识效果
function c84274024.valcheck(e,c)
	local g=c:GetMaterial()
	if c:IsType(TYPE_FUSION) and g:IsExists(Card.IsFusionType,1,nil,TYPE_PENDULUM)
		or c:IsType(TYPE_SYNCHRO) and g:IsExists(Card.IsSynchroType,1,nil,TYPE_PENDULUM)
		or c:IsType(TYPE_XYZ) and g:IsExists(Card.IsXyzType,1,nil,TYPE_PENDULUM) then
		c:RegisterFlagEffect(84274024,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果发动条件：这张卡在魔陷区存在，且自己仅特殊召唤了1只对应类型的怪兽，且该怪兽带有灵摆素材的标识
function c84274024.effcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) and eg:GetCount()==1
		and ec:IsSummonPlayer(tp) and ec:IsFaceup() and ec:IsType(e:GetLabel()) and ec:GetFlagEffect(84274024)~=0
end
-- 融合分支过滤函数：检索卡组中原本等级等于指定数值、且可以守备表示特殊召唤的怪兽
function c84274024.spfilter(c,e,tp,lv)
	local lvl=c:GetOriginalLevel()
	return lvl>0 and lvl==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 融合分支的发动准备：检查怪兽区域空位、卡组中是否存在符合条件的怪兽，以及本回合是否已适用过该效果
function c84274024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在原本等级与那只融合怪兽相同的可特殊召唤怪兽
		and Duel.IsExistingMatchingCard(c84274024.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg:GetFirst():GetOriginalLevel())
		-- 检查本回合是否尚未适用过「灵摆次元」的融合分支效果
		and Duel.GetFlagEffect(tp,84274024)==0 end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 融合分支的效果处理：从卡组选择1只原本等级相同的怪兽，效果无效并以守备表示特殊召唤，并注册本回合已适用该效果的标记
function c84274024.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已适用过该效果，则不处理
	if Duel.GetFlagEffect(tp,84274024)~=0 then return end
	local c=e:GetHandler()
	-- 检查特殊召唤的融合怪兽是否表侧表示存在，且自己场上是否有空余怪兽区域
	if eg:GetFirst():IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只原本等级与那只融合怪兽相同的怪兽
		local g=Duel.SelectMatchingCard(tp,c84274024.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg:GetFirst():GetOriginalLevel())
		local tc=g:GetFirst()
		-- 若成功选出怪兽，则尝试将其以表侧守备表示特殊召唤（分步处理）
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- ●同调：从卡组把1张「融合」加入手卡。●超量：从卡组把持有那只超量怪兽的阶级数值以下的等级的1只调整加入手卡或特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
	-- 给玩家注册本回合已适用「灵摆次元」融合分支效果的标记
	Duel.RegisterFlagEffect(tp,84274024,RESET_PHASE+PHASE_END,0,1)
end
-- 同调分支过滤函数：检索卡组中的「融合」魔法卡
function c84274024.thfilter1(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 同调分支的发动准备：检查卡组中是否存在「融合」，以及本回合是否已适用过该效果
function c84274024.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c84274024.thfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查本回合是否尚未适用过「灵摆次元」的同调分支效果
		and Duel.GetFlagEffect(tp,84274025)==0 end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 同调分支的效果处理：从卡组把1张「融合」加入手牌，并注册本回合已适用该效果的标记
function c84274024.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已适用过该效果，则不处理
	if Duel.GetFlagEffect(tp,84274025)~=0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张「融合」
	local g=Duel.SelectMatchingCard(tp,c84274024.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 给玩家注册本回合已适用「灵摆次元」同调分支效果的标记
	Duel.RegisterFlagEffect(tp,84274025,RESET_PHASE+PHASE_END,0,1)
end
-- 超量分支过滤函数：检索卡组中等级在超量怪兽阶级以下、且为调整的怪兽（需满足能加入手牌或能特殊召唤的条件）
function c84274024.thfilter2(c,e,tp,ft,rk)
	return c:IsLevelBelow(rk) and c:IsType(TYPE_TUNER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 超量分支的发动准备：检查卡组中是否存在符合条件的调整怪兽，以及本回合是否已适用过该效果
function c84274024.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查卡组中是否存在持有那只超量怪兽阶级数值以下等级的调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84274024.thfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,ft,eg:GetFirst():GetRank())
		-- 检查本回合是否尚未适用过「灵摆次元」的超量分支效果
		and Duel.GetFlagEffect(tp,84274026)==0 end
end
-- 超量分支的效果处理：从卡组选择1只符合条件的调整怪兽，加入手牌或特殊召唤，并注册本回合已适用该效果的标记
function c84274024.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已适用过该效果，或者作为触发源的超量怪兽已变成里侧表示，则不处理
	if Duel.GetFlagEffect(tp,84274026)~=0 or eg:GetFirst():IsFacedown() then return end
	-- 获取当前自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 玩家从卡组选择1只持有那只超量怪兽阶级数值以下等级的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c84274024.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft,eg:GetFirst():GetRank())
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若该怪兽无法加入手牌，或者玩家在选项中选择将其特殊召唤
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的调整怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的调整怪兽加入玩家手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	-- 给玩家注册本回合已适用「灵摆次元」超量分支效果的标记
	Duel.RegisterFlagEffect(tp,84274026,RESET_PHASE+PHASE_END,0,1)
end
