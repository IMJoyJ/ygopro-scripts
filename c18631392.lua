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
	-- 将特殊召唤条件判定值设为永远不成立，使这张卡无法被其他效果特殊召唤，只能通过自身记载的方式特殊召唤。
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
-- 筛选特殊召唤素材：自己场上表侧表示、光属性、且可作为代价送去墓地的怪兽。
function c18631392.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
end
-- 从候选素材中选出2张，要求送墓后自己场上仍有可用怪兽区，并且种族组合为天使族和龙族各1张。
function c18631392.fselect(g,tp)
	-- 验证素材组满足两个条件：送墓后场上仍有空位，且一张是天使族、另一张是龙族。
	return aux.mzctcheck(g,tp) and aux.gfcheck(g,Card.IsRace,RACE_FAIRY,RACE_DRAGON)
end
-- 规则特殊召唤的发动条件：检查自己场上是否存在满足条件的一组2张怪兽，存在时才能进行该特殊召唤。
function c18631392.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有满足素材条件的怪兽群，供后续检查是否存在天使族与龙族的组合。
	local g=Duel.GetMatchingGroup(c18631392.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c18631392.fselect,2,2,tp)
end
-- 规则特殊召唤的素材选择：让玩家从候选怪兽中选出2张，保存选中的素材供处理时送墓；未选出则不能发动。
function c18631392.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可作为素材的怪兽集合，用于玩家选择。
	local g=Duel.GetMatchingGroup(c18631392.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 显示“请选择要送去墓地的卡”的提示，引导玩家选择特殊召唤素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c18631392.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 规则特殊召唤的处理：取出选定的2张素材，将其送去墓地，然后完成特殊召唤。
function c18631392.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的素材怪兽以特殊召唤相关的原因送入墓地，作为特殊召唤的代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 起动效果的发动条件和宣言处理：检查卡组顶部3张中是否有可加入手卡的卡，然后让玩家宣言3个卡名，并将后续效果处理函数绑定到本效果。
function c18631392.anctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家卡组是否能将最上方3张卡送去墓地（即卡组数量足够且允许翻卡/送墓），否则不能发动。
		if not Duel.IsPlayerCanDiscardDeck(tp,3) then return false end
		-- 获取玩家卡组最上方的3张卡，用于检查其中是否有可加入手卡的卡。
		local g=Duel.GetDecktopGroup(tp,3)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 显示“请宣言一个卡名”的提示，准备第一次宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家宣言第1个卡名，用于后续从翻开的卡中检索同名卡。
	local ac1=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 显示“请宣言一个卡名”的提示，准备第二次宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家宣言第2个卡名，用于后续从翻开的卡中检索同名卡。
	local ac2=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 显示“请宣言一个卡名”的提示，准备第三次宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家宣言第3个卡名，用于后续从翻开的卡中检索同名卡。
	local ac3=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	e:SetOperation(c18631392.retop(ac1,ac2,ac3))
end
-- 过滤翻开的卡中卡名与所宣言3个卡名之一相同且可以加入手卡的卡。
function c18631392.hfilter(c,code1,code2,code3)
	return c:IsCode(code1,code2,code3) and c:IsAbleToHand()
end
-- 效果处理函数：翻开卡组顶3张，宣言的卡加入手卡，其余送去墓地，再根据加入手卡数量设置攻击力·守备力。
function c18631392.retop(code1,code2,code3)
	return
		-- 实际执行：确认并翻开卡组顶3张，筛选宣言同名卡加入手卡并展示给对方，剩余卡全送墓，若此卡仍在场上则赋予攻守=加入手卡数量×1000。
		function (e,tp,eg,ep,ev,re,r,rp)
			-- 效果处理时再次确认玩家卡组能否将最上方3张送去墓地；若不能则效果不处理。
			if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
			local c=e:GetHandler()
			-- 翻开卡组最上方3张卡，向双方公开确认。
			Duel.ConfirmDecktop(tp,3)
			-- 取得已翻开的卡组顶部3张卡，作为后续分组处理的对象。
			local g=Duel.GetDecktopGroup(tp,3)
			local hg=g:Filter(c18631392.hfilter,nil,code1,code2,code3)
			g:Sub(hg)
			if hg:GetCount()~=0 then
				-- 声明卡加入手卡属于按效果取走但不洗切的情况，禁用本次操作的自动洗切检查。
				Duel.DisableShuffleCheck()
				-- 将翻开的卡中与宣言卡名相同的卡加入持有者手卡。
				Duel.SendtoHand(hg,nil,REASON_EFFECT)
				-- 向对方展示加入手卡的卡，以确认检索结果。
				Duel.ConfirmCards(1-tp,hg)
				-- 洗切己方手卡，避免因刚才加入的已知卡暴露手牌信息。
				Duel.ShuffleHand(tp)
			end
			if g:GetCount()~=0 then
				-- 在把其余翻开的卡送去墓地前禁用自动洗切检查，保持卡组顺序不被打乱。
				Duel.DisableShuffleCheck()
				-- 将不是宣言卡名的翻开的卡全部送去墓地（原因包含翻开与效果）。
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
			end
			if c:IsRelateToEffect(e) then
				-- 这张卡的攻击力·守备力变成这个效果加入手卡的卡数量×1000的数值。
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
