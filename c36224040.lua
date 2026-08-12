--RUM－ゼアル・フォース
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「希望皇 霍普」怪兽或者「异热同心武器」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，从卡组选1只「异热同心武器」怪兽或者「异热同心从者」怪兽在卡组最上面放置。
-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外才能发动。自己从卡组抽1张。
function c36224040.initial_effect(c)
	-- ①：以自己场上1只超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36224040,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36224040.target)
	e1:SetOperation(c36224040.activate)
	c:RegisterEffect(e1)
	-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36224040,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,36224040)
	-- 把墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c36224040.drcon)
	e2:SetTarget(c36224040.drtg)
	e2:SetOperation(c36224040.drop)
	c:RegisterEffect(e2)
end
-- 检查对象怪兽是否满足作为超量怪兽的条件
function c36224040.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查是否存在满足条件的额外卡组怪兽
		and Duel.IsExistingMatchingCard(c36224040.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 检查对象怪兽是否满足成为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 检查额外卡组中是否存在满足条件的怪兽
function c36224040.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0x7e,0x107f) and mc:IsCanBeXyzMaterial(c)
		-- 检查怪兽是否可以特殊召唤且场上是否有足够位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 过滤函数，用于筛选「异热同心武器」或「异热同心从者」怪兽
function c36224040.dtfilter(c)
	return c:IsSetCard(0x107e,0x207e)
end
-- 设置效果目标为满足条件的场上的超量怪兽
function c36224040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c36224040.filter1(chkc,e,tp) end
	-- 检查是否存在满足条件的场上的超量怪兽和卡组中的异热同心怪兽
	if chk==0 then return Duel.IsExistingTarget(c36224040.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(c36224040.dtfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的场上的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c36224040.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果的发动
function c36224040.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否满足成为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外卡组怪兽
	local g=Duel.SelectMatchingCard(tp,c36224040.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到特殊召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到特殊召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将特殊召唤的怪兽特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 提示玩家选择要放置在卡组最上面的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36224040,2))  --"请选择要放置在卡组最上面的卡"
		-- 选择满足条件的卡组怪兽
		local g=Duel.SelectMatchingCard(tp,c36224040.dtfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将卡组洗切
			Duel.ShuffleDeck(tp)
			-- 将选中的卡移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认卡组最上方的卡
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 判断是否满足效果发动条件
function c36224040.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己基本分是否比对方少2000以上
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
end
-- 设置效果目标为抽卡
function c36224040.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为1
	Duel.SetTargetParam(1)
	-- 设置效果处理信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果的发动
function c36224040.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
