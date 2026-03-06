--The suppression PLUTO
-- 效果：
-- ①：1回合1次，宣言1个卡名才能发动。对方手卡全部确认，那之中有宣言的卡的场合，从以下效果选1个适用。
-- ●选对方场上1只怪兽得到控制权。
-- ●选对方场上1张魔法·陷阱卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。
function c24413299.initial_effect(c)
	-- 效果原文内容：①：1回合1次，宣言1个卡名才能发动。对方手卡全部确认，那之中有宣言的卡的场合，从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24413299,0))  --"宣言卡名"
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c24413299.target)
	e1:SetOperation(c24413299.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：定义过滤函数，用于判断卡片是否为魔法或陷阱类型
function c24413299.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：判断是否满足发动条件，即对方手牌存在且场上存在可改变控制权的怪兽或可破坏的魔法/陷阱卡
function c24413299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 效果作用：检查对方场上是否存在可改变控制权的怪兽
		and (Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		-- 效果作用：检查对方场上是否存在魔法或陷阱卡
		or Duel.IsExistingMatchingCard(c24413299.desfilter,tp,0,LOCATION_ONFIELD,1,nil)) end
	-- 效果作用：提示玩家选择要宣言的卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 效果作用：让玩家宣言一个卡牌编号
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 效果作用：将宣言的卡牌编号设置为连锁参数
	Duel.SetTargetParam(ac)
	-- 效果作用：设置操作信息，记录本次发动的宣言行为
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果作用：处理效果发动后的具体操作流程
function c24413299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 效果作用：确认对方手牌内容
		Duel.ConfirmCards(tp,g)
		-- 效果作用：从连锁信息中获取目标参数（即宣言的卡牌编号）
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local tg=g:Filter(Card.IsCode,nil,ac)
		-- 效果作用：获取对方场上可改变控制权的怪兽组
		local g1=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
		-- 效果作用：获取对方场上魔法或陷阱卡组
		local g2=Duel.GetMatchingGroup(c24413299.desfilter,tp,0,LOCATION_ONFIELD,nil)
		if tg:GetCount()>0 and (g1:GetCount()>0 or g2:GetCount()>0) then
			local op=0
			if g1:GetCount()>0 and g2:GetCount()>0 then
				-- 效果作用：当两种效果都存在时，让玩家选择其中一个效果
				op=Duel.SelectOption(tp,aux.Stringid(24413299,1),aux.Stringid(24413299,2))  --"得到控制权/魔法·陷阱卡破坏"
			elseif g1:GetCount()>0 then
				-- 效果作用：当只有改变控制权效果存在时，让玩家选择该效果
				op=Duel.SelectOption(tp,aux.Stringid(24413299,1))  --"得到控制权"
			else
				-- 效果作用：当只有破坏效果存在时，让玩家选择该效果
				op=Duel.SelectOption(tp,aux.Stringid(24413299,2))+1  --"魔法·陷阱卡破坏"
			end
			if op==0 then
				-- 效果作用：提示玩家选择要改变控制权的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
				local g=g1:Select(tp,1,1,nil)
				local tc=g:GetFirst()
				if tc then
					-- 效果作用：将选中的怪兽控制权转移给玩家
					Duel.GetControl(tc,tp)
				end
			else
				-- 效果作用：提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local g=g2:Select(tp,1,1,nil)
				local tc=g:GetFirst()
				if tc then
					-- 效果作用：显示选中的卡作为对象
					Duel.HintSelection(g)
					-- 效果作用：破坏选中的卡
					if Duel.Destroy(g,REASON_EFFECT)~=0
						-- 效果作用：判断是否满足在自己场上盖放的条件
						and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
						and not tc:IsLocation(LOCATION_HAND+LOCATION_DECK)
						and tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable(true)
						-- 效果作用：询问玩家是否要在自己场上盖放该卡
						and Duel.SelectYesNo(tp,aux.Stringid(24413299,3)) then  --"是否在自己场上盖放？"
						-- 效果作用：中断当前效果处理，使后续处理视为不同时处理
						Duel.BreakEffect()
						-- 效果作用：将破坏的魔法/陷阱卡在自己场上盖放
						Duel.SSet(tp,tc)
					end
				end
			end
		end
		-- 效果作用：将对方手牌洗牌
		Duel.ShuffleHand(1-tp)
	end
end
