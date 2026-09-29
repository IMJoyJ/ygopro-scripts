--異解△審判
-- 效果：
-- ①：对方把怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。选持有和那只怪兽相同属性的自己的除外状态（里侧）的1只「异解△」怪兽加入手卡或特殊召唤（这个回合，这个卡名的这个效果不能选相同属性的怪兽）。这个回合，自己不能把「异解△」卡以外的卡的效果发动。
-- ②：自己卡组数量是0张的场合，自己的「异解△」怪兽和对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力变成0。
local s,id,o=GetID()
-- 初始化卡片效果：注册永续陷阱卡片发动、对方召·特召时取对象回收或特召里侧除外怪兽、卡组为0张时战斗使对方怪兽攻击力变0的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 为单张卡片注册对方召唤和特殊召唤的合并延迟事件监听
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS})
	-- ①：对方把怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。选持有和那只怪兽相同属性的自己的除外状态（里侧）的1只「异解△」怪兽加入手卡或特殊召唤（这个回合，这个卡名的这个效果不能选相同属性的怪兽）。这个回合，自己不能把「异解△」卡以外的卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"回收"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己卡组数量是0张的场合，自己的「异解△」怪兽和对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"攻击力变成0"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 过滤对方场上召唤·特殊召唤成功且可作为效果对象的怪兽
function s.tgfilter(c,e,tp,chk)
	-- 获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)
		-- 检查除外区是否存在对应属性且本回合未选过的「异解△」怪兽
		and (chk or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,c,ft))
end
-- 过滤除外状态（里侧）且与对象相同属性、本回合未选过的可加入手卡或特召的「异解△」怪兽
function s.spfilter(c,e,tp,ec,ft)
	-- 检查是否为除外状态（里侧）的「异解△」怪兽且属性相同且本回合未选择过该属性
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsAttribute(ec:GetAttribute()) and not c:IsAttribute(Duel.GetFlagEffectLabel(tp,id))
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果发动目标判定：选择对方召唤·特殊召唤的1只怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.tgfilter(chkc,e,tp,false) end
	local g=eg:Filter(s.tgfilter,nil,e,tp,false)
	if chk==0 then return g:GetCount()>0 end
	if g:GetCount()==1 then
		-- 将唯一定位的怪兽设为效果对象
		Duel.SetTargetCard(g:GetFirst())
	else
		-- 提示选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local tc=g:Select(tp,1,1,nil)
		-- 将选中的怪兽设为效果对象
		Duel.SetTargetCard(tc)
	end
end
-- 效果处理：选相同属性的除外状态（里侧）「异解△」怪兽加入手卡或特殊召唤，并限制本回合只能发动「异解△」卡的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 获取自己怪兽区域的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 提示选择要操作的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从除外区选择1只满足条件的「异解△」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,tc,ft)
		if #g>0 then
			local sc=g:GetFirst()
			if sc then
				local att=sc:GetAttribute()
				local flag=ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判断是否选择将怪兽加入手卡
				if sc:IsAbleToHand() and (not flag or Duel.SelectOption(tp,1190,1152)==0) then
					-- 将选中的怪兽加入手卡
					Duel.SendtoHand(sc,nil,REASON_EFFECT)
					-- 向对方展示加入手卡的怪兽
					Duel.ConfirmCards(1-tp,sc)
				elseif flag then
					-- 将选中的怪兽表侧表示特殊召唤
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				end
				-- 获取本回合已选择属性的标记值
				local label=Duel.GetFlagEffectLabel(tp,id)
				if label then
					-- 更新本回合已选择过的属性标记位
					Duel.SetFlagEffectLabel(tp,id,label|att)
				else
					-- 注册本回合已选择该属性的玩家标记
					Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,att)
				end
			end
		end
	end
	-- 这个回合，自己不能把「异解△」卡以外的卡的效果发动。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.aclimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册本回合效果发动的限制
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件：不能发动「异解△」卡以外的卡的效果
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x1ed)
end
-- 效果发动条件：卡组为0张且自己的「异解△」怪兽与对方怪兽进行战斗的伤害计算时
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组数量是否为0张
	if Duel.GetMatchingGroupCount(aux.TRUE,e:GetHandlerPlayer(),LOCATION_DECK,0,nil)>0 then return end
	-- 获取战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if not a:IsControler(tp) then a,d=d,a end
	local res=a:IsControler(tp) and a:IsFaceup() and a:IsSetCard(0x1ed) and d:IsControler(1-tp) and d:IsFaceup() and d:IsRelateToBattle() and d:GetAttack()>0
	if res then e:SetLabelObject(d) end
	return res
end
-- 效果发动目标判定：将进行战斗的对方怪兽设为对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabelObject()
	if chk==0 then return d end
	-- 将对方怪兽设为效果对象
	Duel.SetTargetCard(d)
end
-- 效果处理：那只对方怪兽的攻击力变成0
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象的对方怪兽
	local d=Duel.GetFirstTarget()
	if not (d:IsRelateToBattle() and d:IsFaceup() and d:IsControler(1-tp)) then return end
	-- 那只对方怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(0)
	d:RegisterEffect(e1)
end
