--RUM－ゼアル・フォース
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「希望皇 霍普」怪兽或者「异热同心武器」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，从卡组选1只「异热同心武器」怪兽或者「异热同心从者」怪兽在卡组最上面放置。
-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外才能发动。自己从卡组抽1张。
function c36224040.initial_effect(c)
	-- ①：以自己场上1只超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「希望皇 霍普」怪兽或者「异热同心武器」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，从卡组选1只「异热同心武器」怪兽或者「异热同心从者」怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36224040,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36224040.target)
	e1:SetOperation(c36224040.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36224040,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,36224040)
	-- 设置②效果的发动代价：把墓地中的这张卡除外（aux.bfgcost封装了除外自身作为COST的通用处理）。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c36224040.drcon)
	e2:SetTarget(c36224040.drtg)
	e2:SetOperation(c36224040.drop)
	c:RegisterEffect(e2)
end
-- 定义①效果选择对象的筛选器：对象须是自己场上表侧表示的超量怪兽，且额外卡组中存在阶级为其阶级+1的「希望皇 霍普」或「异热同心武器」怪兽可叠放其上，同时对象未受“必须作为超量素材”等素材限制。
function c36224040.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 判定额外卡组中存在满足filter2的候选怪兽（阶级为对象阶级+1且可作为超量素材），以保证效果发动时能够特殊召唤。
		and Duel.IsExistingMatchingCard(c36224040.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 确认对象怪兽可以合法作为超量素材（没有被其他效果强制或禁止作为超量素材）。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 定义额外卡组候选怪兽的筛选器：必须是阶级等于目标阶级+1的「希望皇 霍普」或「异热同心武器」怪兽，能够以对象怪兽为超量素材，并且可以以超量召唤方式特殊召唤到可用的额外怪兽区域。
function c36224040.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0x7e,0x107f) and mc:IsCanBeXyzMaterial(c)
		-- 确认候选怪兽可以以超量召唤的方式被特殊召唤，且从额外卡组特殊召唤时自己场上有空余的额外怪兽区域可用。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 定义从卡组选择放置到卡组顶的卡的筛选器：必须是「异热同心武器」或「异热同心从者」字段的怪兽。
function c36224040.dtfilter(c)
	return c:IsSetCard(0x107e,0x207e)
end
-- ①效果的发动时处理：检查是否有合法的超量怪兽对象且卡组有可放置的字段卡片，然后让玩家选择对象，并设置本效果包含从额外卡组特殊召唤1只怪兽。
function c36224040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c36224040.filter1(chkc,e,tp) end
	-- 发动条件检查：自己场上存在1只满足条件的表侧超量怪兽，并且卡组中存在1张「异热同心武器」或「异热同心从者」怪兽可供放置到卡组顶。
	if chk==0 then return Duel.IsExistingTarget(c36224040.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(c36224040.dtfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送选择对象的提示（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足filter1的超量怪兽作为效果对象，并将其登记为连锁对象。
	Duel.SelectTarget(tp,c36224040.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁包含从额外卡组特殊召唤1只怪兽，用于给其他卡（如星尘龙、王家长眠之谷等）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理流程：取得对象怪兽，确认其仍可作为超量素材且未被无效；选择额外卡组中的1只怪兽，将对象及其原有超量素材全部重叠到新怪兽上，以超量召唤方式特殊召唤，然后从卡组选1张对应字段怪兽放到卡组顶。
function c36224040.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 效果处理时再次检查对象怪兽是否仍可合法作为超量素材；若因其他效果影响无法作为素材，则结束处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的额外怪兽（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只符合filter2的「希望皇 霍普」或「异热同心武器」怪兽，以进行重叠超量召唤。
	local g=Duel.SelectMatchingCard(tp,c36224040.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原有的所有超量素材转移给新选择怪兽，使其继承这些素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原来的对象怪兽本身也叠放到新选择怪兽下方，作为超量素材，实现“重叠在对象怪兽上面”的规则操作。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新选择怪兽以超量召唤方式表侧攻击表示特殊召唤到自己的怪兽区域，完成超量召唤。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 提示玩家选择要放置在卡组最上面的卡（使用脚本中的第3条提示文本）。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36224040,2))  --"请选择要放置在卡组最上面的卡"
		-- 让玩家从卡组选择1张「异热同心武器」或「异热同心从者」怪兽，准备放到卡组顶。
		local g=Duel.SelectMatchingCard(tp,c36224040.dtfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 洗切卡组，以确保接下来放置到卡组顶的操作不暴露卡组顺序。
			Duel.ShuffleDeck(tp)
			-- 将选中的卡移动到卡组最上方，实现“在卡组最上面放置”。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 向双方确认卡组最上面1张卡，展示放置到卡组顶的那张卡。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- ②效果的发动条件判断：自己基本分比对方少2000以上。
function c36224040.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件具体为：自己的LP不大于对方LP减2000（即差值为2000或更多）。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
end
-- ②效果发动时的目标设定：确认可以抽卡，并将抽卡玩家设为自己、抽卡数设为1，同时设置抽卡操作信息。
function c36224040.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己能否通过效果抽1张卡（例如是否被“不能抽卡”效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置该连锁的“目标玩家”为自己，以便处理时知道由谁抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置该连锁的“目标参数”为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本效果包含抽卡分类，目标为自己，数量为1，供抽卡相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理流程：读取之前保存的目标玩家和抽卡数量，然后执行抽卡。
function c36224040.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家（p）和抽卡数量（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
