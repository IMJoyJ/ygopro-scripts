--マアト
-- 效果：
-- 这张卡不能通常召唤。把自己场上表侧表示存在的1只龙族·光属性怪兽和1只天使族·光属性怪兽送去墓地的场合才能特殊召唤。1回合1次，宣言3个卡名才能发动。从自己卡组上面把3张卡翻开，宣言的卡加入手卡。那以外的翻开的卡全部送去墓地。这张卡的攻击力·守备力变成这个效果加入手卡的卡数量×1000的数值。
function c18631392.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为无效（无法特殊召唤）。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上表侧表示存在的1只龙族·光属性怪兽和1只天使族·光属性怪兽送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c18631392.spcon)
	e2:SetTarget(c18631392.sptg)
	e2:SetOperation(c18631392.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，宣言3个卡名才能发动。从自己卡组上面把3张卡翻开，宣言的卡加入手卡。那以外的翻开的卡全部送去墓地。这张卡的攻击力·守备力变成这个效果加入手卡的卡数量×1000的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18631392,0))  --"宣言卡名"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c18631392.anctg)
	c:RegisterEffect(e3)
end
-- 筛选场上表侧表示存在的光属性怪兽作为特殊召唤的消耗对象。
function c18631392.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
end
-- 检查所选的两张怪兽是否分别满足龙族和天使族的种族条件。
function c18631392.fselect(g,tp)
	-- 检查所选的两张怪兽是否分别满足龙族和天使族的种族条件。
	return aux.mzctcheck(g,tp) and aux.gfcheck(g,Card.IsRace,RACE_FAIRY,RACE_DRAGON)
end
-- 检查场上是否存在满足条件的怪兽组合用于特殊召唤。
function c18631392.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有满足条件的怪兽。
	local g=Duel.GetMatchingGroup(c18631392.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c18631392.fselect,2,2,tp)
end
-- 从满足条件的怪兽中选择两张进行特殊召唤。
function c18631392.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有满足条件的怪兽。
	local g=Duel.GetMatchingGroup(c18631392.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c18631392.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选择的怪兽送去墓地完成特殊召唤。
function c18631392.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检查玩家是否可以翻开卡组顶部3张卡。
function c18631392.anctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否可以翻开卡组顶部3张卡。
		if not Duel.IsPlayerCanDiscardDeck(tp,3) then return false end
		-- 获取卡组顶部3张卡。
		local g=Duel.GetDecktopGroup(tp,3)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 提示玩家宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 玩家宣言第一个卡名。
	local ac1=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 提示玩家宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 玩家宣言第二个卡名。
	local ac2=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 提示玩家宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 玩家宣言第三个卡名。
	local ac3=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	e:SetOperation(c18631392.retop(ac1,ac2,ac3))
end
-- 筛选翻开的卡中是否包含宣言的卡。
function c18631392.hfilter(c,code1,code2,code3)
	return c:IsCode(code1,code2,code3) and c:IsAbleToHand()
end
-- 定义效果处理函数，执行翻开卡组、检索卡牌、改变攻击力等操作。
function c18631392.retop(code1,code2,code3)
	return
		-- 执行效果处理函数，包括翻开卡组、检索卡牌、改变攻击力等操作。
		function (e,tp,eg,ep,ev,re,r,rp)
			-- 检查玩家是否可以翻开卡组顶部3张卡。
			if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
			local c=e:GetHandler()
			-- 确认卡组顶部3张卡。
			Duel.ConfirmDecktop(tp,3)
			-- 获取卡组顶部3张卡。
			local g=Duel.GetDecktopGroup(tp,3)
			local hg=g:Filter(c18631392.hfilter,nil,code1,code2,code3)
			g:Sub(hg)
			if hg:GetCount()~=0 then
				-- 禁止接下来的操作进行洗牌检测。
				Duel.DisableShuffleCheck()
				-- 将符合条件的卡加入手牌。
				Duel.SendtoHand(hg,nil,REASON_EFFECT)
				-- 向对方确认翻开的卡。
				Duel.ConfirmCards(1-tp,hg)
				-- 洗切玩家的手牌。
				Duel.ShuffleHand(tp)
			end
			if g:GetCount()~=0 then
				-- 禁止接下来的操作进行洗牌检测。
				Duel.DisableShuffleCheck()
				-- 将不符合条件的卡送去墓地。
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
			end
			if c:IsRelateToEffect(e) then
				-- 将此卡的攻击力设置为加入手牌的卡数量乘以1000。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(hg:GetCount()*1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
				c:RegisterEffect(e2)
			end
		end
end
