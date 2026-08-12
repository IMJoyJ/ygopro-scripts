--結晶魔術 光の涙
-- 效果：
-- 这个卡名在规则上也当作「大贤者」卡、「魔女术」卡使用。
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己场上有「大贤者」怪兽或「魔女术」怪兽存在的场合才能发动。从卡组把1只魔法师族怪兽或1张魔法卡送去墓地。
-- ●对方把效果发动时才能发动。从手卡·卡组把1只「大贤者」怪兽或「魔女术」怪兽特殊召唤。
local s,id,o=GetID()
-- 定义并注册这张卡作为魔法卡发动时的效果。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中满足送去墓地条件的魔法师族怪兽或魔法卡。
function s.tgfilter(c)
	return (c:IsRace(RACE_SPELLCASTER) or c:IsType(TYPE_SPELL)) and c:IsAbleToGrave()
end
-- 过滤手卡或卡组中可以特殊召唤的「大贤者」怪兽或「魔女术」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x128,0x150) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测，根据玩家选择的效果分支进行相应的分类和操作信息注册，并记录一回合一次的限制。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前的连锁序号。
	local ch=Duel.GetCurrentChain()
	-- 检查卡组中是否存在可送去墓地的魔法师族怪兽或魔法卡。
	local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and (not e:IsCostChecked()
			-- 或者在未选择过该效果且自己场上有表侧表示的「大贤者」或「魔女术」怪兽存在。
			or Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x128,0x150))
	-- 检查自己场上是否有空怪兽区域，且手卡或卡组中存在可特殊召唤的「大贤者」或「魔女术」怪兽。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		and (not e:IsCostChecked()
			-- 或者在未选择过该效果且当前连锁是由对方玩家发动效果触发。
			or Duel.GetFlagEffect(tp,id+o)==0 and ch>chk and Duel.GetChainInfo(ch-chk,CHAININFO_TRIGGERING_PLAYER)==1-tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可发动的效果分支中选择一个。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"送去墓地"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
			-- 给玩家注册已使用第一个效果分支的标识，持续到回合结束。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置连锁的操作信息为：从卡组将1张卡送去墓地。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 给玩家注册已使用第二个效果分支的标识，持续到回合结束。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置连锁的操作信息为：从手卡或卡组将1只怪兽特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
	end
end
-- 效果处理的函数，根据玩家在发动时选择的分支执行对应的送墓或特殊召唤处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组选择1张满足条件的魔法师族怪兽或魔法卡。
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡因效果送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡或卡组选择1只满足条件的「大贤者」或「魔女术」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
