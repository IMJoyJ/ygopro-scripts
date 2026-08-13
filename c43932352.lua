--見えざる導き手
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上1只「不可见之手」怪兽或者原本持有者是对方的怪兽解放才能发动。得到对方场上1只怪兽的控制权。
-- ②：自己结束阶段发动。自己场上1张卡送去墓地。
local s,id,o=GetID()
-- 注册并配置三个效果：e1为魔陷发动的空效果，使此卡能发动；e2为①快速效果，获得对方怪兽控制权；e3为②结束阶段必发效果，将自己场上1张卡送去墓地。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：把自己场上1只「不可见之手」怪兽或者原本持有者是对方的怪兽解放才能发动。得到对方场上1只怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"获取控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.ctcost)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段发动。自己场上1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 解放素材过滤函数：候选怪兽必须是「不可见之手」怪兽或原本持有者为对方的怪兽，且解放后自己仍有余裕怪兽区容纳获得控制权的怪兽，同时对方场上还存在其他可被转移控制权的怪兽。
function s.cfilter(c,tp)
	return (c:IsSetCard(0x1d3) or c:GetOwner()==1-tp)
		-- 计算解放候选怪兽后自己场上可用的怪兽区数量，要求大于0，确保取得控制权后能有格子放置怪兽。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在除这只解放候选怪兽外、至少1只能够被改变控制权的怪兽，以保证发动后必有可获取控制权的对象。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,c,true)
end
-- ①效果的代价处理：从自己场上选择并解放1只满足条件的怪兽作为发动代价。
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检测：确认自己场上存在至少1只满足 cfilter 条件的可解放怪兽，否则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 让玩家从自己场上选择1只满足 cfilter 条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 将选择的怪兽以代价（REASON_COST）解放，完成效果发动所需的解放。
	Duel.Release(g,REASON_COST)
end
-- 控制权转移对象的过滤函数：判断怪兽是否可以被改变控制权（即没受到不能转移控制权效果的限制）。
function s.tgfilter(c,ignore)
	return c:IsControlerCanBeChanged(ignore)
end
-- ①效果的发动目标条件：确认对方场上存在可改变控制权的怪兽，并设置操作信息用于后续连锁响应。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：对方场上必须存在至少1只满足 tgfilter 的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,true) end
	-- 设置操作信息：本效果处理时将获得对方场上1只怪兽（怪兽区）的控制权，数量和位置写入连锁信息。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- ①效果处理：实际选择对方场上1只可改变控制权的怪兽，并将控制权转移给自己。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要改变控制权的怪兽，并等待玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上（LOCATION_MZONE）选择1只满足 tgfilter 的怪兽作为控制权转移目标。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,false)
	local tc=g:GetFirst()
	if tc then
		-- 手动显示所选怪兽的被选中动画，并记录这些卡成为本效果对象（广义）。
		Duel.HintSelection(g)
		-- 让 tp 玩家获得所选怪兽的控制权（无期限限制）。
		Duel.GetControl(tc,tp)
	end
end
-- ②效果的发动条件：仅当当前回合玩家是这张卡的控制者/发动者 tp 时才满足（即自己的结束阶段）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果持有者 tp，确保只在己方结束阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的目标条件：允许发动（chk==0 时返回 true），并设置操作信息为自己场上1张卡送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果处理时将自己场上1张卡送去墓地，目标位置为整个场上（主怪兽区+魔陷区+场地）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end
-- ②效果处理：选择自己场上1张卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上（包括怪兽区和魔陷区/场地）选择1张能够送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选卡的选中动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 将选择的那张卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
