--騎士皇レガーティア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。自己抽1张。那之后，可以把对方场上1只攻击力最高的怪兽破坏。
-- ②：攻击力2000以下的自己怪兽不会被战斗破坏。
-- ③：自己·对方的结束阶段才能发动。从自己的手卡·墓地把同调怪兽以外的1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 初始化卡片的同调召唤手续以及①②③效果的创建与注册。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。自己抽1张。那之后，可以把对方场上1只攻击力最高的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ddtg)
	e1:SetOperation(s.ddop)
	c:RegisterEffect(e1)
	-- ②：攻击力2000以下的自己怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.bdtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段才能发动。从自己的手卡·墓地把同调怪兽以外的1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件与处理信息设定：检查自己能否抽1张，并将抽卡对象玩家和数量记录下来。
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己（发动玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（即抽卡数量）。
	Duel.SetTargetParam(1)
	-- 登记操作信息：这次效果处理包含抽卡，抽卡玩家为自己，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理：自己抽1张卡；抽卡后若对方场上有表侧表示怪兽且自己选择发动，则破坏对方场上攻击力最高的怪兽。
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和参数（抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡（成功数量>0），并检查对方场上是否存在表侧表示怪兽。
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 弹出确认提示，询问自己是否要将对方攻击力最高的怪兽破坏（选择“是”才继续处理破坏）。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把对方攻击力最高的怪兽破坏？"
		-- 中断当前效果，使之后的破坏处理与抽卡处理不在同一时点（避免错过时点）。
		Duel.BreakEffect()
		-- 获取对方场上的全部表侧表示怪兽作为候选组。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tg=g:GetMaxGroup(Card.GetAttack)
		if #tg>1 then
			-- 当攻击力最高的怪兽有复数时，显示选择要破坏的卡片的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 手动展示所选择的卡片作为对象，并记录其为效果对象。
			Duel.HintSelection(sg)
			-- 将选中的怪兽以效果原因破坏。
			Duel.Destroy(sg,REASON_EFFECT)
		-- 若攻击力最高的怪兽只有1只，则直接将其破坏。
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
-- ②效果的适用对象筛选：表侧表示且攻击力在2000以下的自己怪兽。
function s.bdtg(e,c)
	return c:IsFaceup() and c:IsAttackBelow(2000)
end
-- ③效果选择卡的过滤条件：持有「百夫长骑士」字段、是怪兽、不是同调怪兽且不在禁止卡之列。
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsType(TYPE_SYNCHRO)
end
-- ③效果的发动条件：自己手卡·墓地存在符合条件的「百夫长骑士」怪兽，且自己魔法与陷阱区域有空位。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己手卡·墓地是否存在至少1张符合条件的「百夫长骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
		-- 并检查自己的魔法与陷阱区域是否有可用空位。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ③效果处理：从自己的手卡·墓地选择1只符合条件的「百夫长骑士」怪兽，将其表侧表示放置到自己的魔法与陷阱区域，并使其变为永续陷阱卡。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认魔法与陷阱区域有空位，否则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 显示选择要放置到场上的卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡·墓地选择1张符合条件的「百夫长骑士」怪兽（若墓地有此类卡则需考虑王家长眠之谷的效果限制）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽卡移动到自己的魔法与陷阱区域，以表侧表示放置，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- ……当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
