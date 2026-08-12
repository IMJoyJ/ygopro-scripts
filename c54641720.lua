--D－HERO ドレッドノートガイ
-- 效果：
-- 5星以上的「命运英雄」怪兽×2
-- 「命运英雄 无惧人」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上1只「命运英雄 恐惧人」解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。把「命运英雄」怪兽或者有那卡名记述的卡合计2张从卡组加入手卡。
-- ②：这张卡的攻击力变成自己的场上·墓地的其他的「命运英雄」怪兽的原本攻击力的合计值。
local s,id,o=GetID()
-- 注册这张卡的全部效果：融合召唤手续、卡名记述（恐惧人）、特殊召唤成功时的回合计数、特殊召唤条件、解放恐惧人的特殊召唤规则、①检索诱发效果和②攻击力变更永续效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：用2只5星以上的「命运英雄」怪兽作为融合素材进行融合召唤
	aux.AddFusionProcFunRep(c,s.mfilter,2,true)
	-- 记录这张卡上记述着「命运英雄 恐惧人」（卡号40591390）的卡名
	aux.AddCodeList(c,40591390)
	-- 「命运英雄 无惧人」1回合1次用融合召唤以及以下方法才能特殊召唤（特殊召唤成功时注册计数标识的部分）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 「命运英雄 无惧人」1回合1次用融合召唤以及以下方法才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- ●把自己场上1只「命运英雄 恐惧人」解放的场合可以从额外卡组特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤的场合才能发动。把「命运英雄」怪兽或者有那卡名记述的卡合计2张从卡组加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"检索"
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- ②：这张卡的攻击力变成自己的场上·墓地的其他的「命运英雄」怪兽的原本攻击力的合计值
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_SET_ATTACK)
	e5:SetValue(s.val)
	c:RegisterEffect(e5)
end
s.material_setcode=0xc008
-- 融合素材的过滤条件：5星以上的「命运英雄」怪兽
function s.mfilter(c)
	return c:IsLevelAbove(5) and c:IsFusionSetCard(0xc008)
end
-- 特殊召唤条件的判定函数：仅限融合召唤，且本回合尚未用此卡特殊召唤过
function s.splimit(e,se,sp,st)
	-- 判断召唤方式是融合召唤，并且该玩家本回合没有这张卡的特殊召唤记录
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 判定条件：这张卡是融合召唤特殊召唤，或带有本回合已通过自身方法特殊召唤过的标识
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 特殊召唤成功时的处理：给玩家注册本回合已特殊召唤过这张卡的标识
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册持续到回合结束的标识效果，记录本回合已特殊召唤过「命运英雄 无惧人」
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤可作为特殊召唤手续解放的「命运英雄 恐惧人」：可以解放、可以作为这张卡的融合素材、且其离场后额外卡组怪兽有出场空格
function s.hspfilter(c,tp,fc)
	return c:IsFusionCode(40591390) and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
		-- 检查该卡离场后，自己场上是否有能让额外卡组怪兽出场的可用空格
		and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0
end
-- 特殊召唤规则的发动条件：本回合未特殊召唤过这张卡，且自己场上存在可解放的「命运英雄 恐惧人」
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若本回合已经特殊召唤过这张卡，则不能再用此方法特殊召唤
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	-- 检查自己场上是否存在至少1只满足条件的可解放的「命运英雄 恐惧人」
	return Duel.CheckReleaseGroupEx(tp,s.hspfilter,1,REASON_SPSUMMON,false,nil,tp,c)
end
-- 特殊召唤手续的目标选择：从自己场上选择1只要解放的「命运英雄 恐惧人」
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放的卡中满足「命运英雄 恐惧人」条件的卡
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.hspfilter,nil,tp,c)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理：给这张卡注册标识并解放选择的怪兽完成特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 解放选择的「命运英雄 恐惧人」作为从额外卡组特殊召唤的手续
	Duel.Release(g,REASON_SPSUMMON)
end
-- 检索的过滤条件：「命运英雄」怪兽或者效果文本记述了「命运英雄」怪兽卡名的卡，且可以加入手卡
function s.thfilter(c)
	-- 判断这张卡是「命运英雄」怪兽，或记述了「命运英雄」怪兽卡名的卡，并且可以加入手卡
	return (c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) or aux.IsSetNameMonsterListed(c,0xc008)) and c:IsAbleToHand()
end
-- ①效果的目标设定：确认卡组有2张可检索的卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己卡组是否存在至少2张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置操作信息：从卡组把2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选2张满足条件的卡加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认卡组仍有2张满足条件的卡，否则中断处理
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) then
		return
	end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择2张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤表侧表示的「命运英雄」怪兽（含墓地）
function s.vfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xc008)
end
-- 计算这张卡的攻击力：自己场上·墓地其他「命运英雄」怪兽原本攻击力的合计值
function s.val(e,c)
	-- 获取自己场上·墓地除这张卡以外的「命运英雄」怪兽
	local g=Duel.GetMatchingGroup(s.vfilter,c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,c)
	return g:GetSum(Card.GetBaseAttack)
end
