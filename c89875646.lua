--トリプル・ヴァレル・リボルブ
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从自己墓地让1只龙族怪兽回到卡组。那之后，可以把和回去的怪兽卡名不同的1只「弹丸」怪兽从卡组特殊召唤。
-- ●从自己墓地让2只龙族怪兽回到卡组。那之后，从自己墓地把1张场地魔法卡加入手卡。
-- ●从自己墓地让3只龙族怪兽回到卡组。那之后，从对方墓地让最多3只怪兽回到卡组。
local s,id,o=GetID()
-- 初始化「三重枪管旋转」(89875646)：注册可从3个1回合各能选1次的分支效果中选择1个发动的魔法卡效果
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。●从自己墓地让1只龙族怪兽回到卡组。那之后，可以把和回去的怪兽卡名不同的1只「弹丸」怪兽从卡组特殊召唤。●从自己墓地让2只龙族怪兽回到卡组。那之后，从自己墓地把1张场地魔法卡加入手卡。●从自己墓地让3只龙族怪兽回到卡组。那之后，从对方墓地让最多3只怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选墓地中可以返回卡组的龙族怪兽
function s.tdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
-- 过滤函数：筛选墓地中可以加入手卡的场地魔法卡
function s.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 过滤函数：筛选对方墓地中可以返回卡组的怪兽卡
function s.tdfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果Target函数：分别检查3个分支的墓地卡片条件及本回合使用次数限制，让玩家从中选择1个分支并设置对应的操作信息与已选标记
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方墓地是否存在至少1只可返回卡组的龙族怪兽（分支1前置条件）
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 且确认无需检查誓约或本回合尚未选择过分支1（标识id为0）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查己方墓地是否存在至少2只可返回卡组的龙族怪兽（分支2前置条件）
	local b2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil)
		-- 且检查己方墓地是否存在至少1张可加入手卡的场地魔法卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 且确认无需检查誓约或本回合尚未选择过分支2（标识id+o为0）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	-- 检查己方墓地是否存在至少3只可返回卡组的龙族怪兽（分支3前置条件）
	local b3=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil)
		-- 且检查对方墓地是否存在至少1只可返回卡组的怪兽
		and Duel.IsExistingMatchingCard(s.tdfilter2,tp,0,LOCATION_GRAVE,1,nil)
		-- 且确认无需检查誓约或本回合尚未选择过分支3（标识id+o*2为0）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o*2)==0)
	if chk==0 then return b1 or b2 or b3 end
	-- 弹出选项让玩家从当前满足条件的分支1、2、3中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"让1只回到卡组"
			{b2,aux.Stringid(id,2),2},  --"让2只回到卡组"
			{b3,aux.Stringid(id,3),3})  --"让3只回到卡组"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
			-- 为己方玩家注册持续至回合结束的分支1已使用标记id
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置分支1将己方墓地1只怪兽返回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 为己方玩家注册持续至回合结束的分支2已使用标记id+o
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
		end
		-- 设置分支2将己方墓地2只怪兽返回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
		-- 设置分支2将己方墓地1张场地魔法加入手卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	elseif op==3 then
		if e:IsCostChecked() then
			-- 为己方玩家注册持续至回合结束的分支3已使用标记id+o*2
			Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_TODECK)
		end
		-- 设置分支3将双方墓地共计4只（己方3只+对方至少1只）怪兽返回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,4,PLAYER_ALL,LOCATION_GRAVE)
	end
end
-- 过滤函数：筛选卡组中卡名不同于code、属于「弹丸」(0x102)字段且可被特殊召唤的怪兽
function s.spfilter(c,e,tp,code)
	return not c:IsCode(code) and c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：根据所选分支sel（1或2，及3）先将对应数量的己方墓地龙族怪兽洗回卡组，再执行对应的特召「弹丸」、回收场地魔法或洗回对方墓地怪兽处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	-- 检查己方墓地是否存在至少sel只不受「王家长眠之谷」限制且可回卡组的龙族怪兽，不足则中止
	if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,sel,nil) then return end
	if sel==1 then
		-- 分支1提示：向己方玩家发送选择1只返回卡组的龙族怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从己方墓地选择1只不受「王家长眠之谷」限制的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 手动为选中的龙族怪兽显示被选定提示动画
			Duel.HintSelection(g)
			-- 将选中的龙族怪兽洗回卡组（额外卡组），并检查操作数量是否不为0
			if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
				and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
				-- 检查己方主要怪兽区是否仍有可用空位
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 且检查卡组中是否存在至少1只与回去怪兽卡名不同的可特召「弹丸」怪兽
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,tc:GetCode())
				-- 询问己方玩家是否要从卡组特殊召唤1只不同名「弹丸」怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否特殊召唤？"
				-- 向己方玩家发送选择要特殊召唤的「弹丸」怪兽提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从己方卡组中选择1只与回去怪兽卡名不同的「弹丸」怪兽
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
				if sg:GetCount()>0 then
					-- 中断当前处理步骤，使后续卡组特召与前面的回卡组视为不同时处理（“那之后”）
					Duel.BreakEffect()
					-- 将选中的「弹丸」怪兽以表侧表示特殊召唤到己方场上
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	elseif sel==2 then
		-- 分支2提示：向己方玩家发送选择2只返回卡组的龙族怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从己方墓地选择2只不受「王家长眠之谷」限制的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,2,2,nil)
		if g:GetCount()==2 then
			-- 手动为选中的2只龙族怪兽显示被选定提示动画
			Duel.HintSelection(g)
			-- 将选中的2只龙族怪兽洗回卡组（额外卡组），并检查操作数量是否不为0
			if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
				and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==2
				-- 且确认2只均已返回卡组/额外卡组后，检查己方墓地是否存在不受「王家长眠之谷」限制的场地魔法卡
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) then
				-- 向己方玩家发送选择要加入手卡的场地魔法卡提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 从己方墓地选择1张不受「王家长眠之谷」限制的场地魔法卡
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
				if sg:GetCount()>0 then
					-- 以效果将选中的场地魔法卡加入持有者（己方）手卡
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					-- 向对方玩家公开确认加入手卡的场地魔法卡
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	elseif sel==3 then
		-- 分支3提示：向己方玩家发送选择3只返回卡组的龙族怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从己方墓地选择3只不受「王家长眠之谷」限制的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil)
		if g:GetCount()==3 then
			-- 手动为选中的3只龙族怪兽显示被选定提示动画
			Duel.HintSelection(g)
			-- 将选中的3只龙族怪兽洗回卡组（额外卡组），并检查操作数量是否不为0
			if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
				and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==3
				-- 且确认3只均已返回卡组/额外卡组后，检查对方墓地是否存在不受「王家长眠之谷」限制的怪兽
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter2),tp,0,LOCATION_GRAVE,1,nil) then
				-- 向己方玩家发送选择要洗回对方卡组的怪兽提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
				-- 从对方墓地选择1至3只不受「王家长眠之谷」限制的怪兽
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter2),tp,0,LOCATION_GRAVE,1,3,nil)
				if sg:GetCount()>0 then
					-- 手动为选中的对方墓地怪兽显示被选定提示动画
					Duel.HintSelection(sg)
					-- 以效果将选中的对方墓地怪兽洗回持有者卡组（或额外卡组）
					Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end
