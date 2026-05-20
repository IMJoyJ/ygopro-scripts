--誤出荷
-- 效果：
-- ①：包含从卡组把卡加入手卡效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果变成「对方从自身卡组选1张卡。自己把那张卡加入手卡。自己把这个效果加入手卡的卡持续公开，这个回合的结束阶段，公开中的那张卡回到原本持有者的卡组，自己抽1张。」。
local s,id,o=GetID()
-- 注册卡片效果：在包含检索或抽卡效果的效果发动时可以发动的卡片发动效果。
function s.initial_effect(c)
	-- ①：包含从卡组把卡加入手卡效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果变成
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查发动效果的连锁是否包含抽卡（CATEGORY_DRAW）或检索（CATEGORY_SEARCH）分类。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	return ex4 or ex5
end
-- 过滤条件：可以加入手牌的卡。
function s.thfilter(c)
	return c:IsAbleToHand()
end
-- 效果发动的靶向处理，确认对方卡组中是否存在可以加入手牌的卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动该效果的玩家（rp）的卡组中是否存在至少1张可以加入手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,rp,0,LOCATION_DECK,1,nil) end
end
-- 效果处理：清空原效果的对象，并将该连锁的效果处理函数替换为本卡指定的效果处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将被替换效果的连锁对象更改为空卡片组，防止原效果的对象处理继续生效。
	Duel.ChangeTargetCard(ev,g)
	-- 将该连锁的效果处理函数替换为「对方从自身卡组选1张卡。自己把那张卡加入手卡...」的自定义处理。
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 替换后的效果处理：对方从自身卡组选1张卡，自己加入手卡并持续公开，并在结束阶段注册回到卡组并抽1张卡的效果。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家发送提示信息，提示其选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让对方玩家（1-tp）从其自身的卡组中选择1张可以加入手牌的卡。
	local sg=Duel.SelectMatchingCard(1-tp,s.thfilter,1-tp,LOCATION_DECK,0,1,1,nil)
	local tc=sg:GetFirst()
	-- 如果成功将对方选择的卡加入自己（tp）的手牌。
	if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT)~=0 then
		-- 自己把这个效果加入手卡的卡持续公开
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local fid=tc:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,66)
		-- 这个回合的结束阶段，公开中的那张卡回到原本持有者的卡组，自己抽1张。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.tdcon)
		e2:SetOperation(s.tdop)
		-- 在全局环境中为自己注册该回合结束阶段触发的延迟处理效果。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 结束阶段效果的触发条件：检查该卡是否仍带有对应的标记（即是否仍在手牌且处于公开状态），若标记不符则重置该效果。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段效果的处理：向对方确认该卡，将其送回持有者卡组，然后自己抽1张卡。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 向对方玩家确认该卡（确保洗回卡组的卡是当时加入手牌的那张卡）。
	Duel.ConfirmCards(1-tp,tc)
	-- 将该卡送回原本持有者的卡组并洗牌。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 自己从卡组抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
