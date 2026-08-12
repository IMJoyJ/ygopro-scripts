--SPYRAL－ザ・ダブルヘリックス
-- 效果：
-- 「秘旋谍」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「秘旋谍-花公子」使用。
-- ②：宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，从自己的卡组·墓地选1只「秘旋谍」怪兽加入手卡或在作为这张卡所连接区的自己场上特殊召唤。
function c1322368.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2个以上属于「秘旋谍」系列的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xee),2,2)
	-- 使此卡在场上或墓地存在时视为「秘旋谍-花公子」使用
	aux.EnableChangeCode(c,41091257,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，从自己的卡组·墓地选1只「秘旋谍」怪兽加入手卡或在作为这张卡所连接区的自己场上特殊召唤。
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
-- 过滤满足条件的「秘旋谍」怪兽，用于选择加入手卡或特殊召唤的卡片
function c1322368.spfilter(c,e,tp,zone)
	return c:IsSetCard(0xee) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)))
end
-- 设置效果的发动条件，检查是否满足发动条件
function c1322368.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()
	-- 检查自己卡组是否至少有1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 检查自己卡组或墓地是否存在满足条件的「秘旋谍」怪兽
		and Duel.IsExistingMatchingCard(c1322368.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择卡的种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	-- 记录玩家宣言的卡的种类
	e:SetLabel(Duel.AnnounceType(tp))
	-- 设置连锁操作信息，表示将要特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 设置效果的处理函数，执行效果的处理逻辑
function c1322368.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组是否至少有1张卡
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 确认对方卡组最上方的1张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		-- 从自己卡组或墓地选择满足条件的「秘旋谍」怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1322368.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
		local sc=sg:GetFirst()
		if sc then
			if zone~=0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
				-- 判断是否选择特殊召唤或加入手卡，若选择特殊召唤则进行判断
				and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
				-- 将选中的怪兽特殊召唤到场上
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,zone)
			else
				-- 将选中的怪兽加入手卡
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方确认加入手卡的怪兽
				Duel.ConfirmCards(1-tp,sc)
			end
		end
	end
end
