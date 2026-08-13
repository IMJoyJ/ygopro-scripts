--ジャンク・ウォリアー／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
-- ①：这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000，这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
-- ②：场上的这张卡不受对方发动的怪兽的效果影响。
-- ③：这张卡被破坏的场合，以自己墓地1只「废品战士」为对象才能发动。那只怪兽回到额外卡组。那之后，可以把那只怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 注册此卡全部效果：特殊召唤限制（不能通常召唤，仅可用「爆裂模式」效果特殊召唤）、攻击力上升、不受对方发动怪兽效果影响、被破坏时回收墓地「废品战士」并可选当作同调召唤特殊召唤、与怪兽战斗给对方的战斗伤害翻倍。
function s.initial_effect(c)
	-- 登记此卡文本中记载的卡名：「废品战士」（60800381）和「爆裂模式」（80280737），用于相关检索或判定。
	aux.AddCodeList(c,60800381,80280737)
	-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为aux.AssaultModeLimit：仅当以爆裂体特殊召唤方式或由「爆裂模式」效果特殊召唤时才允许，实现‘不能通常召唤，用「爆裂模式」的效果才能特殊召唤’的限制。
	e0:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e0)
	-- 这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	-- 场上的这张卡不受对方发动的怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- 这张卡被破坏的场合，以自己墓地1只「废品战士」为对象才能发动。那只怪兽回到额外卡组。那之后，可以把那只怪兽当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"回到卡组"
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(s.damcon)
	-- 设置战斗伤害变更效果：把对手因这张卡与怪兽战斗受到的战斗伤害变为2倍（DOUBLE_DAMAGE）。
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
s.assault_name=60800381
-- 定义攻击力上升值的计算函数：计算自己场上表侧表示的「/爆裂体」怪兽数量，每有1只上升1000攻击力。
function s.val(e,c)
	-- 返回自己场上满足s.filter条件的「/爆裂体」怪兽数量乘以1000，作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*1000
end
-- 定义「/爆裂体」怪兽的筛选条件：表侧表示且字段为0x104f（「/爆裂体」）。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x104f)
end
-- 定义免疫效果判定：若效果的发动者不是这张卡的控制者，且该效果为已发动的怪兽效果，则这张卡不受其影响。
function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER)
end
-- 定义对象筛选条件：选择的是「废品战士」（60800381）、同调怪兽、可以返回额外卡组、且原持有者为发动玩家tp。
function s.spfilter(c,e,tp)
	return c:IsCode(60800381) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra() and c:GetOwner()==tp
end
-- ③效果的发动时目标处理：确认存在可选的墓地「废品战士」，由玩家选择1张作为对象，并设置将对象送回额外卡组的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 效果发动时（chk==0）检查自己墓地是否存在至少1张满足条件的「废品战士」；若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示信息“请选择要返回卡组的卡”，用于目标选择时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张符合条件的「废品战士」作为效果对象，并将该卡设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将把对象g送回额外卡组（CATEGORY_TOEXTRA），数量1，供其他效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 效果处理：取得对象，确认其仍与连锁相关且不受王家长眠之谷影响，将其送回额外卡组；成功后若该卡能同调召唤且有空格，询问玩家是否特殊召唤；选择是则中断当前效果，清空其素材，以同调召唤形式特殊召唤并完成同调召唤手续。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡（墓地里的「废品战士」）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		-- 确认对象不受「王家长眠之谷」等效果影响，并将其以效果原因送回持有者的额外卡组；若送回成功（返回>0）则继续。
		and aux.NecroValleyFilter()(tc) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_EXTRA)
		-- 确认对象可以按同调召唤形式特殊召唤，且自己场上有可供额外卡组怪兽特殊召唤的空位。
		and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
		-- 询问玩家是否进行后续的特殊召唤（提示“是否特殊召唤？”），选择“是”才继续。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤单独处理，避免与前面的回额外卡组共用同一时点。
		Duel.BreakEffect()
		tc:SetMaterial(nil)
		-- 将对象「废品战士」以同调召唤形式（SUMMON_TYPE_SYNCHRO）特殊召唤到玩家tp场上，表侧表示，不检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 定义战斗伤害翻倍效果的适用条件：这张卡与怪兽战斗（存在战斗对象）时生效。
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
