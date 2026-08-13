--デメット爺さん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的「珂珑公主」1个超量素材取除才能发动。从自己墓地选最多2只攻击力或守备力是0的通常怪兽作为暗属性·8星怪兽守备表示特殊召唤。
-- ②：自己的超量怪兽把作为超量素材的通常怪兽取除来让效果发动的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽破坏，给与对方作为对象的超量怪兽的阶级×300伤害。
function c44190146.initial_effect(c)
	-- 开启全局标记，使游戏引擎触发超量素材被取除的事件（EVENT_DETACH_MATERIAL），用于检测②效果中‘自己的超量怪兽把作为超量素材的通常怪兽取除来让效果发动’的行为。
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 对应①效果（含‘这个卡名的①②的效果1回合各能使用1次。’的1回合1次限制）：‘把自己的「珂珑公主」1个超量素材取除才能发动。从自己墓地选最多2只攻击力或守备力是0的通常怪兽作为暗属性·8星怪兽守备表示特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44190146,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,44190146)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c44190146.spcost)
	e1:SetTarget(c44190146.sptg)
	e1:SetOperation(c44190146.spop)
	c:RegisterEffect(e1)
	-- 对应②效果：‘自己的超量怪兽把作为超量素材的通常怪兽取除来让效果发动的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽破坏，给与对方作为对象的超量怪兽的阶级×300伤害。’
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44190146,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,44190147)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c44190146.descon)
	e2:SetTarget(c44190146.destg)
	e2:SetOperation(c44190146.desop)
	c:RegisterEffect(e2)
	if not c44190146.global_check then
		c44190146.global_check=true
		-- 对应②效果中‘自己的超量怪兽把作为超量素材的通常怪兽取除来让效果发动的场合’：在超量素材因代价被取除时，检测其中是否包含通常怪兽，若包含则记录该超量怪兽作为候选对象。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetOperation(c44190146.checkop)
		-- 将ge1注册为全局持续效果，使所有超量素材取除事件都会经过checkop处理，以实现②效果发动条件的检测。
		Duel.RegisterEffect(ge1,0)
		-- 对应②效果中‘把作为超量素材的通常怪兽取除’：通过替代取除素材的检测，在超量素材被取除前记录该超量怪兽的素材组，以便checkop计算被取除的素材中是否有通常怪兽。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
		ge2:SetCondition(c44190146.regop)
		-- 将ge2注册为全局持续效果，用于在超量素材被取除时记录素材组，供checkop判断取除的素材是否含通常怪兽。
		Duel.RegisterEffect(ge2,0)
		-- 对应②效果中‘自己的超量怪兽把作为超量素材的通常怪兽取除来让效果发动的场合’的‘场合’判定：在连锁结束时清空本连锁的检测记录，确保②效果只能在取除通常素材的同1个连锁内发动，避免跨连锁残留。
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_CHAIN_END)
		ge3:SetCondition(c44190146.clearop)
		-- 将ge3注册为全局持续效果，在每次连锁结束时清空c44190146[0]和c44190146[1]的记录，避免影响下次效果判定。
		Duel.RegisterEffect(ge3,0)
		c44190146[0]={}
		c44190146[1]={}
	end
end
-- checkop函数：在当前连锁有超量怪兽以取除素材为代价发动效果时，通过比较取除前后的素材组，若取除的素材中存在通常怪兽，则将该超量怪兽的FieldID存入c44190146[0]，作为②效果可发动的候选。
function c44190146.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号，用于随后取回该连锁中发动的效果信息。
	local cid=Duel.GetCurrentChain()
	if cid>0 and (r&REASON_COST)>0 then
		-- 取得当前连锁中发动的效果对象，以获取效果所属的超量怪兽及其控制者等信息。
		local te=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_EFFECT)
		local rc=te:GetHandler()
		if rc:IsRelateToEffect(te) and c44190146[1][rc]~=nil then
			local dg=c44190146[1][rc]-rc:GetOverlayGroup()
			if dg:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
				c44190146[0][rc]=rc:GetFieldID()
			end
		end
	end
	c44190146[1]={}
end
-- regop函数：在超量素材因代价被取除时，把该超量怪兽取除前的素材组保存到c44190146[1][rc]，供checkop检测被取除的素材是否为通常怪兽；返回false表示不实际干预取除过程。
function c44190146.regop(e,tp,eg,ep,ev,re,r,rp)
	if (r&REASON_COST)==REASON_COST and re:IsActiveType(TYPE_XYZ) then
		local rc=re:GetHandler()
		c44190146[1][rc]=rc:GetOverlayGroup()
	end
	return false
end
-- clearop函数：在连锁结束时清空c44190146[0]和c44190146[1]，使记录只保留在当前连锁内，保证②效果的‘场合’判定正确。
function c44190146.clearop(e,tp,eg,ep,ev,re,r,rp)
	c44190146[0]={}
	c44190146[1]={}
end
-- costfilter函数：定义①效果的代价可用卡——自己场上的「珂珑公主」（卡号75574498）且表侧表示，并能够取除1个超量素材。
function c44190146.costfilter(c,tp)
	return c:IsCode(75574498) and c:IsFaceup() and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- spcost函数：执行①效果的代价，从自己场上选择1只符合条件的「珂珑公主」，取除其1个超量素材（REASON_COST）。
function c44190146.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查是否存在满足条件的「珂珑公主」可以支付代价；若不存在则①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44190146.costfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出‘请选择要取除超量素材的怪兽’的选择提示，引导玩家选择支付代价的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 通过选择界面选取1张符合条件的「珂珑公主」作为支付代价的卡，并取其第一张。
	local tc=Duel.SelectMatchingCard(tp,c44190146.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	tc:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- filter函数：定义①效果可特殊召唤的怪兽——墓地的通常怪兽，攻击力或守备力为0，并且可以被效果以表侧守备表示特殊召唤。
function c44190146.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- sptg函数：①效果的发动目标条件——自己场上有空余怪兽区，且墓地存在至少1只满足filter条件的通常怪兽。
function c44190146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余怪兽区，作为①效果能否发动的场地条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足filter条件的通常怪兽，作为①效果的发动条件之一。
		and Duel.IsExistingMatchingCard(c44190146.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本效果含特殊召唤，预计从墓地特殊召唤1只怪兽（实际处理时可为2只），用于相关效果的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- spop函数：①效果的实际处理——根据空位和【青眼精灵龙】的限制确定本次最多特殊召唤1只或2只，从墓地选择满足条件的通常怪兽，以守备表示特殊召唤，并赋予以暗属性·8星的效果。
function c44190146.spop(e,tp,eg,ep,ev,re,r,rp)
	local max=2
	-- 处理开始时若自己场上没有空余怪兽区，则直接结束效果处理，不进行特殊召唤。
	if Duel.GetMZoneCount(tp)<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetMZoneCount(tp)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then max=1 end
	-- 弹出‘请选择要特殊召唤的卡’的选择提示，供玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1~max只满足filter条件且不受‘王家长眠之谷’影响的通常怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c44190146.filter),tp,LOCATION_GRAVE,0,1,max,nil,e,tp)
	-- 遍历选出的怪兽，对每只怪兽逐一执行特殊召唤和赋予等级/属性的处理。
	for tc in aux.Next(g) do
		-- 将当前怪兽以表侧守备表示特殊召唤到己方场上（特殊召唤手续的其中一步，需由Duel.SpecialSummonComplete完成）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 对应①效果中‘作为暗属性·8星怪兽’的‘8星’部分：给特殊召唤的怪兽附加等级变为8的永续效果。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对应①效果中‘作为暗属性·8星怪兽’的‘暗属性’部分：给特殊召唤的怪兽附加属性变为暗的永续效果。
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(ATTRIBUTE_DARK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成所有SpecialSummonStep组成的特殊召唤，触发特殊召唤成功时的各种时点。
	Duel.SpecialSummonComplete()
end
-- descon函数：②效果的发动条件——当前连锁中发动的效果的控制者是自己，且该效果所属的超量怪兽正是c44190146[0]中记录的、取除了通常素材发动效果的那只超量怪兽。
function c44190146.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsControler(tp) and rc:GetFieldID()==c44190146[0][rc]
end
-- destg函数：②效果的取对象流程——以记录中的那只超量怪兽和对方场上1只怪兽为对象，并保存超量怪兽到e:SetLabelObject；设置伤害和破坏的操作信息。
function c44190146.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rc=re:GetHandler()
	if chk==0 then return rc:IsCanBeEffectTarget(e)
		-- 检查对方场上是否存在至少1只可以成为对象的怪兽，作为②效果的发动条件之一。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出‘请选择效果的对象’的选择提示，用于指定己方的那只超量怪兽为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	e:SetLabelObject(rc)
	local dmg=rc:GetRank()*300
	-- 将记录中的超量怪兽设为当前连锁的对象卡，使其与②效果建立关联，后续处理中可通过连锁对象取得。
	Duel.SetTargetCard(rc)
	-- 弹出‘请选择要破坏的卡’的选择提示，用于选择对方场上要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象，并加入当前连锁的对象列表（与超量怪兽一起构成两个对象）。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将对对方造成dmg点伤害（dmg=超量怪兽阶级×300），用于连锁中伤害相关效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
	-- 设置操作信息：将破坏对象g（对方怪兽）的效果登记到当前连锁，用于连锁中破坏相关效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- desop函数：②效果的实际处理——从连锁对象中取出对方怪兽和作为对象的超量怪兽；对方怪兽仍与效果相关时将其破坏，若破坏成功且超量怪兽仍与效果相关并表侧表示，则给对方造成其阶级×300伤害。
function c44190146.desop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	-- 取得当前连锁的全部对象卡（包括己方超量怪兽和对方怪兽），用于效果处理时区分两者。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==rc then tc=g:GetNext() end
	-- 判断要破坏的对方怪兽是否仍与效果相关；若相关则将其破坏，并检查破坏是否实际成功。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and rc:IsRelateToEffect(e) and rc:IsFaceup() then
		-- 给对方造成相当于作为对象的超量怪兽阶级×300的伤害，造成伤害的原因为效果。
		Duel.Damage(1-tp,rc:GetRank()*300,REASON_EFFECT)
	end
end
