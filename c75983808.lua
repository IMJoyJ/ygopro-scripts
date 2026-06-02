--混沌のマジック・ボックス
-- 效果：
-- ①：自己场上的其他卡为对象的效果由对方发动时才能发动。那些自己的卡之内1张回到手卡（里侧表示卡翻开确认），场上1张卡破坏。那之后，可以把和回到手卡的卡卡名不同的有「光与暗的仪式」的卡名记述的1只怪兽从手卡无视召唤条件特殊召唤。
-- ②：这张卡被对方破坏的场合才能发动。从手卡·卡组把有「光与暗的仪式」的卡名记述的1只仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 注册“混沌之魔术箱”的卡片效果：注册效果文本中记述有「光与暗的仪式」卡名的关联，卡片发动效果①（自己被选为对象的卡回手、场上卡破坏、特召记载怪兽），以及被对方破坏时的触发效果②（特召记载仪式怪兽）。
function s.initial_effect(c)
	-- 在此卡的关联列表中加入卡片「光与暗的仪式」（卡号33599853）。
	aux.AddCodeList(c,33599853)
	-- ①：自己场上的其他卡为对象的效果由对方发动时才能发动。那些自己的卡之内1张回到手卡（里侧表示卡翻开确认），场上1张卡破坏。那之后，可以把和回到手卡的卡卡名不同的有「光与暗的仪式」的卡名记述的1只怪兽从手卡无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合才能发动。从手卡·卡组把有「光与暗的仪式」的卡名记述的1只仪式怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否在自己场上、可以回到手牌。
function s.cfilter(c,tp)
	return c:IsAbleToHand() and c:IsOnField() and c:IsControler(tp)
end
-- 效果①的发动条件：对方发动了以自己场上除这张卡以外的其他卡片为对象的效果的场合。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandlerPlayer()~=1-tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取引发该连锁效果的发动时所指定的广义对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- 效果①的发动准备（Target）：检查场上除这张卡之外是否有至少2张卡存在；从对方效果指定的对象中筛选出符合回手条件的己方卡片并设为效果对象；设置这些己方卡片回手以及场上卡片破坏的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上除了这张卡以外的所有卡片。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return g:GetCount()>1 end
	-- 过滤获取对方发动效果所指定的对象中，属于己方场上且可以回到手牌的卡片。
	local sg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(s.cfilter,nil,tp)
	-- 将这些被指定且符合条件的卡片设置为该连锁的处理对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将选中的对象卡片中至少1张回到手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
	-- 设置操作信息：破坏场上的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：检索手牌中卡名不同于回到手牌的卡，且卡片文本中记述有「光与暗的仪式」卡名、是怪兽、能够无视召唤条件特殊召唤的卡片。
function s.spfilter(c,e,tp,ec)
	-- 检查卡片效果文本上是否记述着「光与暗的仪式」卡名，且是怪兽卡。
	return aux.IsCodeListed(c,33599853) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and not c:IsCode(ec:GetCode())
end
-- 效果①的效果处理（Operation）：将对方指定的己方对象卡中的1张回到手牌（若里侧表示则翻开确认）；之后破坏场上1张卡；那之后，可以由玩家选择从手牌将1只卡名不同于回手卡片且记述有「光与暗的仪式」的怪兽无视召唤条件特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前发动效果的卡片对象（在仍在场上的情况下排除此卡）。
	local c=aux.ExceptThisCard(e)
	-- 筛选与当前连锁相关且属于自己场上、可以回到手牌的卡片。
	local g=Duel.GetTargetsRelateToChain():Filter(s.cfilter,c,tp)
	if g:GetCount()==0 then return end
	-- 给玩家显示“选择要返回手牌的卡”的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if tc then
		-- 给选中的卡片显示被选为对象的视觉提示动画效果。
		Duel.HintSelection(sg)
		if tc:IsFacedown() then
			-- 如果被选中的卡是里侧表示的，将其翻开向对方确认。
			Duel.ConfirmCards(1-tp,tc)
		end
		-- 尝试将目标卡片以效果原因送入玩家手牌，并确认该卡片已成功加入手牌。若成功则继续执行后续处理。
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
			-- 给玩家显示“选择要破坏的卡”的系统提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家从场上选择1张要破坏的卡（排除这张卡自身）。
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
			if dg:GetCount()>0 then
				-- 给选中的要破坏的卡显示对应的视觉提示动画效果。
				Duel.HintSelection(dg)
				-- 尝试以效果原因破坏选中的卡片，若成功破坏则继续执行后续处理。
				if Duel.Destroy(dg,REASON_EFFECT)~=0 then
					-- 获取手牌中满足特殊召唤条件的符合要求怪兽卡（记述有「光与暗的仪式」且卡名与回手机会不同的怪兽）。
					local ssg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp,tc)
					if ssg:GetCount()>0
						-- 检查己方主要怪兽区域是否还有可用的空位。
						and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
						-- 让玩家选择是否特殊召唤手牌中的怪兽。
						and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
						-- 中断效果处理，使后续的特殊召唤处理与前面的破坏处理不视为同时进行。
						Duel.BreakEffect()
						-- 给玩家显示“选择要特殊召唤的卡”的系统提示信息。
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
						local sssg=ssg:Select(tp,1,1,nil)
						-- 将选中的怪兽无视召唤条件，以表侧表示特殊召唤到发动者的场上。
						Duel.SpecialSummon(sssg,0,tp,tp,true,false,POS_FACEUP)
					end
				end
			end
		end
	end
end
-- 效果②的发动条件：这张卡被对方破坏且之前由己方控制的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤函数：检索卡片文本中记述有「光与暗的仪式」卡名、是仪式怪兽、并且能够特殊召唤的卡片。
function s.spfilter2(c,e,tp)
	-- 检查卡片效果文本上是否记述着「光与暗的仪式」卡名，且同时是怪兽卡与仪式怪兽卡。
	return aux.IsCodeListed(c,33599853) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动准备（Target）：检查手牌或卡组是否存在可特殊召唤的仪式怪兽、怪兽区域是否有空位，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定：检查己方手牌或卡组中是否存在至少1张满足特殊召唤条件的符合要求仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		-- 发动判定：检查己方主要怪兽区域是否还有可用的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：从手牌或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的效果处理（Operation）：在主要怪兽区域有空位的情况下，让玩家从手牌或卡组选择1张记述有「光与暗的仪式」的仪式怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理判定：如果己方主要怪兽区域已经没有可用空位，则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“选择要特殊召唤的卡”的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组中选择1张符合特殊召唤条件的仪式怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的仪式怪兽无视召唤条件，以表侧表示特殊召唤到发动者的场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
