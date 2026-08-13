--混沌幻魔アーミタイル－虚無幻影羅生悶
-- 效果：
-- 「神炎皇 乌利亚」＋「降雷皇 哈蒙」＋「幻魔皇 拉比艾尔」
-- ①：这张卡只要在怪兽区域存在，卡名当作「混沌幻魔 阿米泰尔」使用。
-- ②：1回合1次，自己主要阶段才能发动。这张卡的控制权移给对方。
-- ③：这张卡的控制权转移的回合的结束阶段发动。自己场上的卡全部除外。那之后，这张卡的原本持有者可以从自身的额外卡组把1只「混沌幻魔 阿米泰尔」无视召唤条件特殊召唤。
function c60110982.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「神炎皇 乌利亚」（6007213）、「降雷皇 哈蒙」（32491822）、「幻魔皇 拉比艾尔」（69890967）为融合素材，允许素材替代及融合素材组等融合方式。
	aux.AddFusionProcCode3(c,6007213,32491822,69890967,true,true)
	-- 使这张卡在怪兽区域存在期间，卡名当作「混沌幻魔 阿米泰尔」（43378048）使用，对应①效果。
	aux.EnableChangeCode(c,43378048)
	-- 对应②效果：“②：1回合1次，自己主要阶段才能发动。这张卡的控制权移给对方。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60110982,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c60110982.cttg)
	e2:SetOperation(c60110982.ctop)
	c:RegisterEffect(e2)
	-- 对应③效果中“这张卡的控制权转移的回合”这一条件，登记控制权变更并记录标记。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CONTROL_CHANGED)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c60110982.regop)
	c:RegisterEffect(e3)
	-- 对应③效果：“③：这张卡的控制权转移的回合的结束阶段发动。自己场上的卡全部除外。那之后，这张卡的原本持有者可以从自身的额外卡组把1只「混沌幻魔 阿米泰尔」无视召唤条件特殊召唤。”
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(60110982,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c60110982.rmcon)
	e4:SetTarget(c60110982.rmtg)
	e4:SetOperation(c60110982.rmop)
	c:RegisterEffect(e4)
end
-- ②效果的发动条件检测：满足发动条件时判断此卡是否允许被变更控制权，并设置相应操作信息。
function c60110982.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged() end
	-- 设置本次连锁的操作信息为“变更控制权”，对象为本卡、数量1，用于时点及对应卡检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- ②效果处理时，若此卡仍在场上且与效果相关，则将控制权转移给对手。
function c60110982.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡的控制权转移给当前玩家的对手（1-tp）。
		Duel.GetControl(c,1-tp)
	end
end
-- 当本卡控制权变更时，给本卡注册一个专用标记（FlagEffect 60110982），该标记持续到结束阶段，用于确认本回合发生过控制权转移。
function c60110982.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(60110982,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③效果的发动条件：结束阶段时本卡带有“控制权已转移”的标记才满足条件。
function c60110982.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(60110982)>0
end
-- ③效果发动前，不取对象地检索当前控制者场上所有可除外的卡，并设置“除外”操作信息。
function c60110982.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前控制者（tp）场上所有满足“可以除外”条件的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,nil)
	-- 将本次连锁的操作信息设为“除外”，目标为这些可除外的卡，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 定义③效果额外特召的筛选条件：从额外卡组选1只卡号为43378048的「混沌幻魔 阿米泰尔」，要求其可被本次效果无视召唤条件特殊召唤，且有足够空格。
function c60110982.spfilter(c,e,p)
	-- 判断候选卡是否为「混沌幻魔 阿米泰尔」、能否被无视召唤条件特殊召唤，以及额外怪兽是否可出场。
	return c:IsCode(43378048) and c:IsCanBeSpecialSummoned(e,0,p,true,false) and Duel.GetLocationCountFromEx(p,p,nil,c)>0
end
-- ③效果的处理：先取原持有者p；除外当前控制者场上所有可除外的卡；若除外成功且原持有者额外卡组有符合条件的「混沌幻魔 阿米泰尔」，则由原持有者选择是否特殊召唤。
function c60110982.rmop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	-- 获取当前控制者（tp）场上所有能除外的卡，用于效果处理时一并除外。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,nil)
	-- 若存在可除外的卡，就将其表侧表示除外，并确认至少1张卡实际被除外且位于除外区，否则不进行后续特殊召唤。
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
		-- 若原持有者的额外卡组存在符合条件的「混沌幻魔 阿米泰尔」且原持有者选择“是”，则继续执行特殊召唤。
		and Duel.IsExistingMatchingCard(c60110982.spfilter,p,LOCATION_EXTRA,0,1,nil,e,p) and Duel.SelectYesNo(p,aux.Stringid(60110982,2)) then  --"是否特殊召唤「混沌幻魔 阿米泰尔」？"
		-- 中断当前效果链，使后续“除外后再特殊召唤”作为独立时点处理，对应原文“那之后”。
		Duel.BreakEffect()
		-- 提示原持有者选择要特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让原持有者从自己的额外卡组选择1只符合条件的「混沌幻魔 阿米泰尔」。
		local sg=Duel.SelectMatchingCard(p,c60110982.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p)
		-- 将选择的「混沌幻魔 阿米泰尔」无视召唤条件、表侧表示特殊召唤到原持有者场上。
		Duel.SpecialSummon(sg,0,p,p,true,false,POS_FACEUP)
	end
end
