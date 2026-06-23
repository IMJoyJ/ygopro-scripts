--闇の神－ダークゴッド
-- 效果：
-- ①：这张卡可以把自己场上2只恶魔族·天使族怪兽解放从手卡特殊召唤。
-- ②：这张卡不会被战斗破坏。
-- ③：1回合1次，可以发动。在自己场上把「暗之神衍生物」（恶魔族·暗·10星·攻3000/守1000）尽可能特殊召唤。这衍生物不能直接攻击，不会被战斗破坏，这张卡破坏时破坏。这个回合，自己不能把怪兽特殊召唤。
-- ④：怪兽被战斗破坏的场合发动。给与对方700伤害。
local s,id,o=GetID()
-- 注册卡片的效果：①规则特殊召唤效果、②战斗抗性效果、③起动效果特殊召唤衍生物并限制特召、④怪兽被战斗破坏伤害效果。
function s.initial_effect(c)
	-- ①：这张卡可以把自己场上2只恶魔族·天使族怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：1回合1次，可以发动。在自己场上把「暗之神衍生物」（恶魔族·暗·10星·攻3000/守1000）尽可能特殊召唤。这衍生物不能直接攻击，不会被战斗破坏，这张卡破坏时破坏。这个回合，自己不能把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	-- ④：怪兽被战斗破坏的场合发动。给与对方700伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"给与伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
-- 定义过滤函数：过滤出属于恶魔族或天使族，且处于己方控制下或在场上表侧表示的卡片。
function s.rfilter(c,tp)
	return c:IsRace(RACE_FAIRY+RACE_FIEND) and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤的条件检查函数：如果卡片不存在则返回成功，否则确认当前玩家场上是否拥有两只可解放的怪兽，并且在解放之后主怪兽区域仍有空格来放置特殊召唤的本卡。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家可解放的卡片组，并使用过滤函数筛选出符合条件的恶魔族·天使族怪兽。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.rfilter,nil,tp)
	-- 检查筛选后的怪兽组中是否存在至少有一组包含2只怪兽的子集，这2只怪兽可以正常被解放且解放后场上仍有空位。
	return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 手牌特殊召唤的区域选择函数：筛选可解放的恶魔族·天使族怪兽，提示并让玩家选择2只怪兽解放，并将选中的怪兽组绑定在效果的标签对象中。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的卡片组，并使用过滤函数筛选出符合条件的恶魔族·天使族怪兽。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.rfilter,nil,tp)
	-- 向玩家发送选择提示信息：请选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从过滤后的怪兽中选择符合“解放2只怪兽且解放后怪兽区域仍有空格”的怪兽组。
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的实际操作函数：获取绑定的怪兽卡片组，将它们全部解放，并销毁该卡片组对象。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤原因解放选中的怪兽卡片组。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 起动效果的发动检查：判断是否满足至少召唤1只衍生物的条件（主怪兽区是否有空位以及玩家是否可特殊召唤代币怪兽）。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件检测，检查自己主要怪兽区域是否还有可用的格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家当前是否能够将代币「暗之神衍生物」（恶魔族·暗·10星·攻3000/守1000）特殊召唤到怪兽区。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,3000,1000,10,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 获取玩家主要怪兽区域可特殊召唤的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置操作信息：包含在怪兽区域特殊召唤代币卡片的分类，数量为当前场上的空格数。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置操作信息：包含特殊召唤的分类，数量为当前场上的空格数。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end
-- 起动效果的实际处理过程：在场上尽可能地特殊召唤「暗之神衍生物」，为每一只代币怪兽注册不会被战斗破坏、不能直接攻击、本卡被破坏时其代币也被破坏的效果，并施加本回合自己不能特殊召唤怪兽的限制限制。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家主要怪兽区域可特殊召唤的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断主要怪兽区域是否仍有空格，并且玩家能否特殊召唤代币怪兽。
	if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,3000,1000,10,RACE_FIEND,ATTRIBUTE_DARK) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local fid=e:GetHandler():GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD,0,1,fid)
		for i=1,ft do
			-- 在内存中生成对应的衍生物代币卡片。
			local token=Duel.CreateToken(tp,id+o)
			-- 以表侧表示的形式将该衍生物卡片特殊召唤到场上（不完成最后的结算）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 不会被战斗破坏
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			-- 这衍生物不能直接攻击
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e2,true)
			-- 这张卡破坏时破坏。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCode(EVENT_LEAVE_FIELD)
			e3:SetLabelObject(c)
			e3:SetLabel(fid)
			e3:SetCondition(s.descon)
			e3:SetOperation(s.desop)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e3)
		end
		-- 完成对上述所有进行的特殊召唤步骤的最终结算处理。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将「这个回合不能特殊召唤怪兽」的限制效果注册到全局环境中，并对当前玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 代币被破坏自爆效果的触发条件检查：确保不是该代币本身被破坏，同时检查是否是本卡（暗之神）被破坏且其所带有的FieldID标识与效果绑定的标识匹配。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=e:GetLabelObject()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY) and tc:GetFlagEffectLabel(id)==e:GetLabel()
end
-- 代币被破坏自爆效果的实际操作函数：将本代币卡片进行效果破坏操作。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 由于效果原因，将当前代币卡片自身进行破坏处理。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 给与伤害效果的发动检测和处理准备：设置目标玩家为对方玩家，目标伤害值为700，并设置操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果连锁的对象玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的效果对象参数为伤害值700。
	Duel.SetTargetParam(700)
	-- 设置操作信息：包含对对方玩家造成700点效果伤害的分类。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
-- 给与伤害效果的实际处理过程：获取连锁绑定的目标玩家和伤害参数，对该玩家造成效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前处理的连锁信息中获取目标玩家和伤害数值参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成计算出的效果伤害数值。
	Duel.Damage(p,d,REASON_EFFECT)
end
