--リンクロス
-- 效果：
-- 连接2以上的连接怪兽1只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。把最多有那只作为连接素材的连接怪兽的连接标记数量的「连接衍生物」（电子界族·光·1星·攻/守0）在自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不能把「连接衍生物」作为连接素材。
function c85243784.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要1只满足特定过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c85243784.mfilter,1)
	-- ①：这张卡连接召唤成功的场合才能发动。把最多有那只作为连接素材的连接怪兽的连接标记数量的「连接衍生物」（电子界族·光·1星·攻/守0）在自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不能把「连接衍生物」作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85243784,0))
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,85243784)
	e1:SetCondition(c85243784.tkcon)
	e1:SetTarget(c85243784.tktg)
	e1:SetOperation(c85243784.tkop)
	c:RegisterEffect(e1)
end
-- 过滤条件：连接2以上的连接怪兽
function c85243784.mfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:GetLink()>=2
end
-- 发动条件：这张卡连接召唤成功
function c85243784.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动时的目标选择与可行性检查
function c85243784.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=e:GetHandler():GetMaterial()
	if mg:GetCount()~=1 then return false end
	-- 检查作为连接素材的怪兽是否存在且自己场上有可用的怪兽区域
	if chk==0 then return mg:IsExists(Card.IsType,1,nil,TYPE_LINK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤「连接衍生物」（电子界族·光·1星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,48068379,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	e:SetLabel(mg:GetFirst():GetLink())
	-- 设置连锁信息：包含产生衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁信息：包含特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：在自己场上特殊召唤对应数量的「连接衍生物」，并适用不能将其作为连接素材的限制
function c85243784.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=e:GetLabel()
	-- 检查是否有可用空格、素材连接标记数是否大于0，以及是否能特殊召唤衍生物
	if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,48068379,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then
		local count=math.min(ft,ct)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
		if count>1 then
			local num={}
			local i=1
			while i<=count do
				num[i]=i
				i=i+1
			end
			-- 提示玩家选择要特殊召唤的衍生物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(85243784,1))  --"请选择要特殊召唤的衍生物的数量"
			-- 让玩家宣言一个数字作为特殊召唤的衍生物数量
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		repeat
			-- 创建「连接衍生物」卡片数据
			local token=Duel.CreateToken(tp,85243785)
			-- 逐步将衍生物以表侧表示特殊召唤到自己场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			count=count-1
		until count==0
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不能把「连接衍生物」作为连接素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置限制效果的对象为「连接衍生物」
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,48068379))
	e1:SetValue(c85243784.lklimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中为玩家注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：由该效果的发动玩家控制的卡不能作为连接素材
function c85243784.lklimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
