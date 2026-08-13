--The suppression PLUTO
-- 效果：
-- ①：1回合1次，宣言1个卡名才能发动。对方手卡全部确认，那之中有宣言的卡的场合，从以下效果选1个适用。
-- ●选对方场上1只怪兽得到控制权。
-- ●选对方场上1张魔法·陷阱卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。
function c24413299.initial_effect(c)
	-- ①：1回合1次，宣言1个卡名才能发动。对方手卡全部确认，那之中有宣言的卡的场合，从以下效果选1个适用。●选对方场上1只怪兽得到控制权。●选对方场上1张魔法·陷阱卡破坏。那之后，可以把破坏的那张魔法·陷阱卡在自己场上盖放。
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
-- 定义过滤器函数，判断卡片是否为魔法·陷阱卡，用于检索对方场上可破坏的魔陷。
function c24413299.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的条件检查：要求对方手牌有卡，且对方场上有可夺控怪兽或可破坏魔陷。
function c24413299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在至少1张卡，作为发动条件之一。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 检查对方场上是否存在至少1只可改变控制权的怪兽，作为可选效果目标。
		and (Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		-- 检查对方场上是否存在至少1张可破坏的魔法·陷阱卡，作为可选效果目标。
		or Duel.IsExistingMatchingCard(c24413299.desfilter,tp,0,LOCATION_ONFIELD,1,nil)) end
	-- 向发动玩家显示提示，要求其宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言1个卡名，并限制不能宣言融合·同调·超量·连接怪兽，返回宣言的卡号。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号存入连锁参数中，供效果处理时判断对方手卡中是否存在同名卡。
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息，标记本效果包含宣言卡名的类别，供连锁和时点判定使用。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理阶段：确认对方手牌，若存在宣言卡名，则从夺取控制权和破坏魔陷中选择一项适用；破坏魔陷后还可选择是否在自己场上盖放，最后洗切对方手牌。
function c24413299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌整体作为组对象，用于确认与筛选。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 将对方手牌内容展示给发动玩家确认。
		Duel.ConfirmCards(tp,g)
		-- 取出当前连锁中保存的宣言卡号。
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local tg=g:Filter(Card.IsCode,nil,ac)
		-- 筛选出对方场上可被改变控制权的怪兽集合。
		local g1=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
		-- 筛选出对方场上可被破坏的魔法·陷阱卡集合。
		local g2=Duel.GetMatchingGroup(c24413299.desfilter,tp,0,LOCATION_ONFIELD,nil)
		if tg:GetCount()>0 and (g1:GetCount()>0 or g2:GetCount()>0) then
			local op=0
			if g1:GetCount()>0 and g2:GetCount()>0 then
				-- 当对方场上既有可夺控怪兽也有可破坏魔陷时，让发动玩家从两个效果中择一。
				op=Duel.SelectOption(tp,aux.Stringid(24413299,1),aux.Stringid(24413299,2))  --"得到控制权/魔法·陷阱卡破坏"
			elseif g1:GetCount()>0 then
				-- 当只有可夺控怪兽时，让发动玩家选择“得到控制权”（固定为第一项）。
				op=Duel.SelectOption(tp,aux.Stringid(24413299,1))  --"得到控制权"
			else
				-- 当只有可破坏魔陷时，让发动玩家选择“破坏”（通过+1映射到第二项分支）。
				op=Duel.SelectOption(tp,aux.Stringid(24413299,2))+1  --"魔法·陷阱卡破坏"
			end
			if op==0 then
				-- 提示发动玩家选择要获得控制权的对方怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
				local g=g1:Select(tp,1,1,nil)
				local tc=g:GetFirst()
				if tc then
					-- 将选中的对方怪兽控制权转移给发动玩家。
					Duel.GetControl(tc,tp)
				end
			else
				-- 提示发动玩家选择要破坏的对方魔法·陷阱卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local g=g2:Select(tp,1,1,nil)
				local tc=g:GetFirst()
				if tc then
					-- 为被选中的破坏对象播放选择动画，并将其记录为效果对象。
					Duel.HintSelection(g)
					-- 以效果原因破坏选中的卡，并检查是否破坏成功。
					if Duel.Destroy(g,REASON_EFFECT)~=0
						-- 判断被破坏卡是否为场地魔法或自己魔陷区是否有空位，以决定可否盖放。
						and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
						and not tc:IsLocation(LOCATION_HAND+LOCATION_DECK)
						and tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable(true)
						-- 询问发动玩家是否将被破坏的魔陷盖放在自己场上。
						and Duel.SelectYesNo(tp,aux.Stringid(24413299,3)) then  --"是否在自己场上盖放？"
						-- 中断当前效果处理，使盖放动作与其他处理分离时点。
						Duel.BreakEffect()
						-- 将被破坏的魔法·陷阱卡以里侧表示盖放在自己场上。
						Duel.SSet(tp,tc)
					end
				end
			end
		end
		-- 将对方手牌洗切，以恢复确认前的顺序。
		Duel.ShuffleHand(1-tp)
	end
end
