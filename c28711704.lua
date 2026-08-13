--トゥーン・カオス・ソルジャー
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上把等级合计直到8以上的卡通怪兽解放的场合可以特殊召唤。
-- ①：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ②：1回合1次，自己场上有「卡通世界」存在的场合，以场上1张卡为对象才能发动。那张卡除外。这个效果发动的回合，这张卡不能攻击。
function c28711704.initial_effect(c)
	-- 将卡名“卡通世界”（15259703）登记为这张卡上记载的卡名，用于相关检索与判定。
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把等级合计直到8以上的自己的手卡·场上的卡通怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c28711704.hspcon)
	e1:SetTarget(c28711704.hsptg)
	e1:SetOperation(c28711704.hspop)
	c:RegisterEffect(e1)
	-- ①：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c28711704.dircon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上有「卡通世界」存在的场合，以场上1张卡为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28711704,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c28711704.rmcon)
	e3:SetCost(c28711704.rmcost)
	e3:SetTarget(c28711704.rmtg)
	e3:SetOperation(c28711704.rmop)
	c:RegisterEffect(e3)
end
-- 筛选可作为特殊召唤解放的卡通怪兽：卡通族、等级1以上，且由tp控制或表侧表示。
function c28711704.rfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsType(TYPE_TOON) and c:IsLevelAbove(1)
end
-- 检查所选一组卡是否满足特殊召唤条件：等级合计至少8，解放后我方怪兽区有空位，且这些卡可作为特殊召唤的合法解放素材。
function c28711704.fselect(g,tp)
	-- 将当前选中的解放候选组设为已选状态，供后续等级合计计算使用。
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,8)
		-- 确认解放这组卡后我方怪兽区仍有空位，并且这组卡可通过特殊召唤理由合法解放。
		and Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_SPSUMMON,true,nil,g)
end
-- 特殊召唤规则的条件判断：c为空时表示可尝试特殊召唤；否则检查是否存在一组卡通怪兽可作为解放素材且满足等级合计8以上等条件。
function c28711704.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得tp可解放的卡片组（含手卡），并筛选出符合条件的卡通怪兽。
	local rg=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c28711704.rfilter,c,tp)
	return rg:CheckSubGroup(c28711704.fselect,1,rg:GetCount(),tp)
end
-- 特殊召唤规则的目标选择：从可解放的卡通怪兽中选取一组满足条件，保存到效果标签，供后续解放；选择成功才允许特殊召唤。
function c28711704.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得可解放的卡通怪兽组，用于选择解放素材。
	local rg=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c28711704.rfilter,c,tp)
	-- 向玩家tp提示“请选择要解放的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c28711704.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则操作：取出之前选定的解放素材组并将其解放，完成特殊召唤手续。
function c28711704.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以“特殊召唤”为理由解放选中的卡通怪兽组。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 判断卡是否为表侧表示的“卡通世界”（卡号15259703）。
function c28711704.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 判断卡是否为表侧表示的卡通怪兽（类型包含TYPE_TOON）。
function c28711704.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的条件：自己场上有表侧表示的“卡通世界”，且对方场上没有表侧表示的卡通怪兽。
function c28711704.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1张表侧表示的“卡通世界”。
	return Duel.IsExistingMatchingCard(c28711704.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上不存在表侧表示的卡通怪兽。
		and not Duel.IsExistingMatchingCard(c28711704.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- ②效果的发动条件：自己场上有表侧表示的“卡通世界”。
function c28711704.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上存在至少1张表侧表示的“卡通世界”，作为②效果的发动条件。
	return Duel.IsExistingMatchingCard(c28711704.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果的发动代价：本回合尚未进行过攻击宣言；发动后给自己附加“不能攻击”的誓约效果（持续到回合结束）。
function c28711704.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- ②：1回合1次，自己场上有「卡通世界」存在的场合，以场上1张卡为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
-- ②效果的目标选择：选择场上1张可以除外的卡作为对象，并设置除外操作信息。
function c28711704.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 效果发动时确认场上存在至少1张可以除外的卡，满足取对象要求。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家tp提示“请选择要除外的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张场上可除外的卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次操作信息为除外1张卡，供其他效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果处理：取得对象卡，若仍与效果关联则将其除外。
function c28711704.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡（取对象的效果处理时取出目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外，处理原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
