--陀羅威
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以这个回合有在场上把效果发动过的自己·对方的主要怪兽区域1只表侧表示怪兽为对象才能发动。那只怪兽破坏，这张卡在那只怪兽存在过的区域特殊召唤。
local s,id,o=GetID()
-- 初始化效果，注册手卡发动的起动效果，并注册用于记录场上怪兽效果发动的全局效果
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以这个回合有在场上把效果发动过的自己·对方的主要怪兽区域1只表侧表示怪兽为对象才能发动。那只怪兽破坏，这张卡在那只怪兽存在过的区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以这个回合有在场上把效果发动过的自己·对方的主要怪兽区域1只表侧表示怪兽为对象才能发动。那只怪兽破坏，这张卡在那只怪兽存在过的区域特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		-- 注册全局效果，用于监听并记录场上怪兽效果的发动
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局效果处理：当怪兽在场上发动效果且连锁处理完毕时，给该怪兽添加标记，标记持续到回合结束
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re) or not re:IsActiveType(TYPE_MONSTER) then return end
	-- 获取当前处理的连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_MZONE then
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤函数：选择主要怪兽区域表侧表示、本回合在场上发动过效果、且其离开后能让自身特殊召唤到该区域的怪兽
function s.filter(c,e,tp)
	local p,seq=c:GetControler(),c:GetSequence()
	-- 判断怪兽是否表侧表示、是否有发动过效果的标记，且该怪兽离开后其所在的怪兽区域是否可用
	return c:IsFaceup() and c:GetFlagEffect(id)>0 and Duel.GetMZoneCount(p,c,tp,LOCATION_REASON_TOFIELD,1<<seq)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p)
end
-- 效果1的发动准备：选择符合条件的怪兽作为对象，并设置破坏与特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	-- 在发动阶段，判断场上是否存在符合条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置破坏操作信息，包含选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置特殊召唤操作信息，包含手卡中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1的效果处理：破坏对象怪兽，并将这张卡特殊召唤到该怪兽原本存在的区域
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	local p,seq=tc:GetControler(),tc:GetSequence()
	-- 若对象怪兽仍适用效果，则将其破坏；若破坏成功且自身仍在手卡，则进行后续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到被破坏怪兽原本所在的怪兽区域
		Duel.SpecialSummon(c,0,tp,p,false,false,POS_FACEUP,1<<seq)
	end
end
