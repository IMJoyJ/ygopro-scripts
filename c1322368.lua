--SPYRAL－ザ・ダブルヘリックス
-- 效果：
-- 「秘旋谍」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「秘旋谍-花公子」使用。
-- ②：宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，从自己的卡组·墓地选1只「秘旋谍」怪兽加入手卡或在作为这张卡所连接区的自己场上特殊召唤。
function c1322368.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只「秘旋谍」怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xee),2,2)
	-- 为这张卡注册卡名变更效果：只要在场上·墓地存在，卡名当作「秘旋谍-花公子」（41091257）使用。
	aux.EnableChangeCode(c,41091257,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，从自己的卡组·墓地选1只「秘旋谍」怪兽加入手卡或在作为这张卡所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1322368,0))  --"宣言卡的种类"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1322368)
	e2:SetTarget(c1322368.sptg)
	e2:SetOperation(c1322368.spop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：从卡组·墓地中选出「秘旋谍」怪兽，且该怪兽能够加入手卡，或者在存在连接区的情况下能够特殊召唤到这张卡的连接区。
function c1322368.spfilter(c,e,tp,zone)
	return c:IsSetCard(0xee) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)))
end
-- ②效果的发动条件判定：获取这张卡的连接区；若对方卡组有卡，且自己卡组·墓地存在符合条件的「秘旋谍」怪兽，则允许发动。
function c1322368.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()
	-- 发动条件检查之一：对方卡组最上方必须有卡，否则效果不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 发动条件检查之二：自己卡组·墓地中是否存在至少1只符合条件的「秘旋谍」怪兽（可加入手卡或可特殊召唤到连接区）。
		and Duel.IsExistingMatchingCard(c1322368.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 为玩家显示选择卡牌种类的提示（怪兽·魔法·陷阱）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 由玩家宣言卡的种类（怪兽·魔法·陷阱），并把宣言结果存入效果的Label，供后续处理判断。
	e:SetLabel(Duel.AnnounceType(tp))
	-- 设置操作信息：本效果包含特殊召唤，预定从自己卡组·墓地处理1只怪兽（具体对象在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：确认对方卡组最上面的卡，若与宣言种类一致，则从自己卡组·墓地选1只「秘旋谍」怪兽加入手卡或特殊召唤到本卡的连接区。
function c1322368.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若对方卡组没有卡，则本次效果不处理并结束。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 确认对方卡组最上方的1张卡，给双方玩家确认。
	Duel.ConfirmDecktop(1-tp,1)
	-- 取得对方卡组最上方的1张卡，用于判断其种类是否与宣言一致。
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 为玩家显示选择要操作的卡的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从自己卡组·墓地选择1只符合条件的「秘旋谍」怪兽，过滤条件中排除了王家长眠之谷等无效影响。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1322368.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
		local sc=sg:GetFirst()
		if sc then
			if zone~=0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
				-- 若该卡不能加入手卡，或玩家选择了“特殊召唤”选项，则执行特殊召唤分支；否则执行加入手卡分支。
				and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
				-- 将选中的「秘旋谍」怪兽以表侧表示特殊召唤到这张卡所连接区的自己场上。
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,zone)
			else
				-- 将选中的「秘旋谍」怪兽加入持有者的手卡（效果处理）。
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 将加入手卡的那张卡给对方玩家确认。
				Duel.ConfirmCards(1-tp,sc)
			end
		end
	end
end
