--天声の服従
-- 效果：
-- ①：支付2000基本分，宣言1个怪兽卡名才能发动。对方把自身卡组确认，有宣言的怪兽的场合，把那之内的1只给双方确认从以下效果选择1个适用。
-- ●确认的卡加入把这张卡发动的玩家手卡。
-- ●确认的卡在把这张卡发动的玩家场上无视召唤条件攻击表示特殊召唤。
function c39238953.initial_effect(c)
	-- 对应效果原文：①：支付2000基本分，宣言1个怪兽卡名才能发动。对方把自身卡组确认，有宣言的怪兽的场合，把那之内的1只给双方确认从以下效果选择1个适用。●确认的卡加入把这张卡发动的玩家手卡。●确认的卡在把这张卡发动的玩家场上无视召唤条件攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c39238953.cost)
	e1:SetTarget(c39238953.target)
	e1:SetOperation(c39238953.activate)
	c:RegisterEffect(e1)
end
-- 效果发动代价子函数：检查并支付2000基本分作为发动代价，对应效果原文“支付2000基本分”。
function c39238953.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：判定玩家是否能支付2000基本分，不能则效果无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际支付2000基本分，作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- target子函数前半段：在chk==0时进行发动合法性判定，要求对方卡组存在可加入手卡的卡或当前玩家可进行特殊召唤，满足其一才允许发动。
function c39238953.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组中是否存在至少1张可加入手卡的卡，用于确保有可确认的卡组卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil)
		-- 或检查当前玩家是否允许特殊召唤，作为发动条件之一，因为效果可能选择特殊召唤。
		or Duel.IsPlayerCanSpecialSummon(tp) end
	-- 发动时提示当前玩家宣言1个怪兽卡名（HINTMSG_CODE），对应“宣言1个怪兽卡名”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	-- 通过Duel.AnnounceCard让玩家宣言1个怪兽卡名，并应用预置过滤条件（只能宣言非融合·同调·超量·连接的怪兽），返回宣言卡号ac。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的怪兽卡号ac保存为连锁对象参数（CHAININFO_TARGET_PARAM），供效果处理阶段使用。
	Duel.SetTargetParam(ac)
	-- 设置操作信息，标记本次效果包含“宣言卡名”（CATEGORY_ANNOUNCE）类别，用于相关判定。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理子函数：获取宣言卡号，确认对方卡组，由对方选择1只宣言怪兽给双方确认，再判断可适用的分支并执行加入手卡或特殊召唤，最后洗切卡组。
function c39238953.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得先前的宣言怪兽卡号，存入变量ac。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取对方卡组中的全部卡片作为候选集合g。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
	if g:GetCount()<1 then return end
	-- 让对方玩家确认自身卡组的所有卡片，对应“对方把自身卡组确认”。
	Duel.ConfirmCards(1-tp,g)
	-- 提示对方玩家从卡组中选择1张要展示的宣言怪兽，作为“给双方确认”的对象。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg=g:FilterSelect(1-tp,Card.IsCode,1,1,nil,ac)
	local tc=sg:GetFirst()
	if tc then
		-- 将对方选择的宣言怪兽展示给发动者玩家确认，完成“给双方确认”。
		Duel.ConfirmCards(tp,sg)
		local b1=tc:IsAbleToHand()
		-- 检查发动者玩家场上主要怪兽区域是否有空位，用于判断能否选择特殊召唤分支。
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK,tp)
		local sel=0
		if b1 and b2 then
			-- 两个效果均可适用时，提示对方玩家选择要适用的效果（加入手卡或特殊召唤）。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 弹出选项菜单让对方在“加入手卡”与“特殊召唤”之间选择，选择结果加1后存入sel（1=手卡，2=特召）。
			sel=Duel.SelectOption(1-tp,aux.Stringid(39238953,0),aux.Stringid(39238953,1))+1  --"加入手卡/特殊召唤"
		elseif b1 then
			-- 只有“加入手卡”可用时，提示对方玩家选择该效果。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 弹出仅含“加入手卡”的选项，选择结果加1后sel为1，对应执行加入手卡。
			sel=Duel.SelectOption(1-tp,aux.Stringid(39238953,0))+1  --"加入手卡"
		elseif b2 then
			-- 只有“特殊召唤”可用时，提示对方玩家选择该效果。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 弹出仅含“特殊召唤”的选项，选择结果加2后sel为2，对应执行特殊召唤。
			sel=Duel.SelectOption(1-tp,aux.Stringid(39238953,1))+2  --"特殊召唤"
		end
		if sel==1 then
			-- 将确认的宣言怪兽加入发动者玩家手卡，对应“确认的卡加入把这张卡发动的玩家手卡”。
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
			-- 将加入手卡的那只宣言怪兽再次展示给对方确认，完成公开确认。
			Duel.ConfirmCards(1-tp,sg)
		elseif sel==2 then
			-- 将确认的宣言怪兽以攻击表示特殊召唤到发动者场上，参数指定不检查召唤条件，对应“无视召唤条件攻击表示特殊召唤”。
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP_ATTACK)
		end
	end
	-- 效果处理完毕后洗切对方卡组，恢复卡组顺序。
	Duel.ShuffleDeck(1-tp)
end
