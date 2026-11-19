--ジャンク・ウォリアー／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
-- ①：这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000，这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
-- ②：场上的这张卡不受对方发动的怪兽的效果影响。
-- ③：这张卡被破坏的场合，以自己墓地1只「废品战士」为对象才能发动。那只怪兽回到额外卡组。那之后，可以把那只怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，登记关联卡名并依次注册特殊召唤限制、①攻击力上升与战斗伤害翻倍效果、②不受对方怪兽发动效果影响效果，以及③被破坏时回收并特召「废品战士」效果
function s.initial_effect(c)
	-- 登记卡片文本中记述的关联卡名「废品战士」和「爆裂模式」
	aux.AddCodeList(c,60800381,80280737)
	-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制判定，只允许通过「爆裂模式」的效果或爆裂体特召方式进行特殊召唤
	e0:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e0)
	-- ①：这张卡的攻击力上升自己场上的「/爆裂体」怪兽数量×1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡不受对方发动的怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，以自己墓地1只「废品战士」为对象才能发动。那只怪兽回到额外卡组。那之后，可以把那只怪兽当作同调召唤作特殊召唤。
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
	-- 设置伤害变更值，使对方受到的这次战斗伤害变为2倍
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
s.assault_name=60800381
-- 计算①效果提供的攻击力上升数值：统计自己怪兽区表侧表示的「/爆裂体」怪兽数量并乘以1000
function s.val(e,c)
	-- 获取自己怪兽区符合条件的「/爆裂体」怪兽数量并乘以1000返回
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*1000
end
-- 过滤场上可用于计算加攻的怪兽：须为表侧表示且属于「/爆裂体」字段
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x104f)
end
-- 判断②效果的免疫条件：当效果由对方发动且处于发动状态、且为怪兽效果时返回真使其不受影响
function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤自己墓地中可作为③效果对象的怪兽：卡名为「废品战士」、属于同调怪兽、能够回到额外卡组且原本持有者为自己
function s.spfilter(c,e,tp)
	return c:IsCode(60800381) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra() and c:GetOwner()==tp
end
-- ③效果的发动检查与取对象处理：检查墓地存在符合条件的「废品战士」，让玩家选择其中1只作为对象，并登记将其送回额外卡组的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只可作为对象的「废品战士」
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动玩家发送选择要返回卡组（额外卡组）的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让发动玩家从自己墓地选择1只「废品战士」作为本次连锁的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁包含将对象怪兽返回额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 执行③效果处理：确认墓地对象仍与连锁关联且不受王家长眠之谷限制后使其回到额外卡组，若成功进入额外卡组且满足素材与额外怪兽区空位条件，可询问玩家并将其当作同调召唤表侧表示特殊召唤且完成苏生限制程序
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选中的墓地「废品战士」
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		-- 检查该怪兽不受王家长眠之谷限制后将其以效果返回额外卡组并确认操作成功
		and aux.NecroValleyFilter()(tc) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_EXTRA)
		-- 检查自己场上不存在强制要求必须作为同调素材使用的效果限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查该「废品战士」能否被当作同调召唤特殊召唤，且自己场上有足够容纳它的额外卡组怪兽出场格位
		and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
		-- 询问发动玩家是否要把返回额外卡组的「废品战士」当作同调召唤特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 中断当前效果处理流程，使之后的特殊召唤视为“那之后”的非同时处理
		Duel.BreakEffect()
		tc:SetMaterial(nil)
		-- 将该「废品战士」当作同调召唤以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 检查①效果战斗伤害翻倍的适用条件：确认当前自身正在与怪兽进行战斗
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
